module seekers_galxe::nft{
    use std::option;
    use std::signer;
    use std::signer::address_of;
    use std::string;
    use std::debug;
    use std::error;
    use aptos_std::string_utils;
    use aptos_framework::account;
    use aptos_framework::account::SignerCapability;
    use aptos_framework::event;
    use std::object::{Self, Object, TransferRef, ConstructorRef};
    use aptos_token_objects::collection;
    use aptos_token_objects::token;
    use aptos_token_objects::token::Token;
    use aptos_std::table;
    use aptos_std::table::Table;


    const RESOURCECAPSEED : vector<u8> = b"Seekers_Galxe";

    const ENOT_TOKEN_OWNER: u64 = 1;

    const ALREADY_MINTED: u64 = 2;

    const NFT_NOT_FOUND: u64 = 3;

    const CollectionDescription: vector<u8> = b"Seekers Alliance NFTs";

    const CollectionName: vector<u8> = b"Seekers Alliance";

    const CollectionURI: vector<u8> = b"ipfs://QmaUpTqFz6eM3Zcpeg9ZJee81ZzA1xi3iURB3DBsSVzJeL";

    const TokenURI: vector<u8> = b"ipfs://QmaUpTqFz6eM3Zcpeg9ZJee81ZzA1xi3iURB3DBsSVzJeL/";


    struct ResourceCap has key {
        cap: SignerCapability
    }


    struct Content has key {
        content: string::String
    }

   struct TokenRef has key {
      burn_ref: token::BurnRef,
      transfer_ref: TransferRef,
   }

   struct History has key {
      history: Table<address, u64>,
      mint_amount: Table<u64, u256>
   }


    #[event]
    struct MintEvent has drop, store {
        owner: address,
        token: address,
        content: string::String
    }


    #[event]
    struct BurnEvent has drop, store {
        owner: address,
        tokenId: address,
    }

    #[event]
    struct TransferEvent has drop, store {
        from: address,
        to: address,
        tokenId: address
    }

    fun init_module(sender: &signer) {

        let (resource_signer, resource_cap) = account::create_resource_account(
            sender, RESOURCECAPSEED
        );

        move_to(&resource_signer, ResourceCap{ cap:resource_cap });

        collection::create_unlimited_collection(
            &resource_signer,
            string::utf8(CollectionDescription),
            string::utf8(CollectionName),
            option::none(),
            string::utf8(CollectionURI)
        );

        let history = History{
            history: table::new(),
            mint_amount: table::new()
        };
        move_to(sender, history);

    }
    


    public entry fun mint(sender: &signer, content: string::String, id: u64) acquires ResourceCap, History {
        // TEST
        /* assert!(!minted, error::permission_denied(ALREADY_MINTED)); */
        assert!(id < 6, error::invalid_argument(NFT_NOT_FOUND));

        let resource_cap = &borrow_global<ResourceCap>(account::create_resource_address(
            &@seekers_galxe, RESOURCECAPSEED
        )).cap;
        let resource_signer = &account::create_signer_with_capability(resource_cap);
        let name;
        if(id==0){
            name = string::utf8(b"Agent K9 #");
        }else if(id==1){
            name = string::utf8(b"Officer Katz #");
        }else if(id==2){
            name = string::utf8(b"Juvenile Punk #");
        }else if(id==3){
            name = string::utf8(b"Cyborg-Gunner #");
        }else if(id==4){
            name = string::utf8(b"Dragonkin Scout #");
        }else
            name = string::utf8(b"Princess Erato #");
        
        

        let token_constructor_ref  = token::create_numbered_token(
            resource_signer,
            string::utf8(CollectionName),
            string::utf8(CollectionDescription),
            name,
            string::utf8(b""),
            option::none(),
            string::utf8(TokenURI),
        );

        //auto set token's picture
        let uri = string::utf8(TokenURI);
        
        string::append(&mut uri, string_utils::to_string(&id));
        string::append(&mut uri, string::utf8(b".json"));
        let token_mutator_ref = token::generate_mutator_ref(&token_constructor_ref);
        token::set_uri(&token_mutator_ref, uri);

        let token_signer = object::generate_signer(&token_constructor_ref);
        

        move_to(&token_signer, TokenRef{
            burn_ref: token::generate_burn_ref(&token_constructor_ref),
            transfer_ref: object::generate_transfer_ref(&token_constructor_ref)
        } 
        );

        event::emit(
            MintEvent{
                owner: signer::address_of(sender),
                token: object::address_from_constructor_ref(&token_constructor_ref),
                content
            }
        );

        object::transfer(
            resource_signer,
            object::object_from_constructor_ref<Token>(&token_constructor_ref),
            signer::address_of(sender),
        );

        // update history
        let history = borrow_global_mut<History>(@seekers_galxe);
        table::upsert(&mut history.history, address_of(sender), id);
        let current_mint_amount = *table::borrow_with_default(&history.mint_amount, id, &0);
        table::upsert(&mut history.mint_amount, id, current_mint_amount + 1);
        // debug::print(&current_mint_amount);

        // object::object_from_constructor_ref(&token_constructor_ref)

        
    }
    

    public entry fun transfer(from: &signer, token: Object<Token>, to: address,) acquires TokenRef{

            // redundant error checking for clear error message
        assert!(object::is_owner(token, signer::address_of(from)), error::permission_denied(ENOT_TOKEN_OWNER));
        let token_ref = borrow_global<TokenRef>(object::object_address(&token));

        // generate linear transfer ref and transfer the token object
        let linear_transfer_ref = object::generate_linear_transfer_ref(&token_ref.transfer_ref);
        object::transfer_with_ref(linear_transfer_ref, to);

        event::emit(
            TransferEvent{
                from: signer::address_of(from),
                to,
                tokenId: object::object_address(&token),
            }
        );
    }

    public entry fun burn(sender: &signer, token: Object<Token>) acquires TokenRef{

        assert!(object::is_owner(token, signer::address_of(sender)), error::permission_denied(ENOT_TOKEN_OWNER));

        let TokenRef{ burn_ref, transfer_ref } = move_from<TokenRef>(object::object_address(&token));

        token::burn(burn_ref);

        event::emit(
            BurnEvent{
                owner: signer::address_of(sender),
                tokenId: object::object_address(&token),
            }
        );


    }
    #[view]
    public fun get_mint_NFT(sender: address):string::String acquires History {

        let history = borrow_global<History>(@seekers_galxe);
        let nft_id:u64 = *table::borrow_with_default(&history.history, sender, &99);
       
        if(nft_id==0){
            return string::utf8(b"Agent K9")
        }else if(nft_id==1){
            return string::utf8(b"Officer Katz")
        }else if(nft_id==2){
            return string::utf8(b"Juvenile Punk")
        }else if(nft_id==3){
            return string::utf8(b"Cyborg-Gunner")
        }else if(nft_id==4){
            return string::utf8(b"Dragonkin Scout")
        }else if(nft_id==5){
            return string::utf8(b"Princess Erato")
        }else{
            return string::utf8(b"NOT FOUND")
        }
    }
    #[view]
    public fun check_player_minted(sender: address):u32 acquires History {

        let history = borrow_global<History>(@seekers_galxe);
        if(table::contains(&history.history, sender)){
            return 1
        }else{
            return 0
        }
    }
    #[view]
    public fun get_mint_amount(idx: u64):u256 acquires History {
        let history = borrow_global<History>(@seekers_galxe);
        let amount = *table::borrow_with_default(&history.mint_amount, idx, &0);
        amount
    }

    #[test_only]
    public fun mint_test(sender: &signer, content: string::String, id: u64):Object<Token> acquires ResourceCap, History {
        // TEST
        /* assert!(!minted, error::permission_denied(ALREADY_MINTED)); */
        assert!(id < 6, error::invalid_argument(NFT_NOT_FOUND));

        let resource_cap = &borrow_global<ResourceCap>(account::create_resource_address(
            &@seekers_galxe, RESOURCECAPSEED
        )).cap;
        let resource_signer = &account::create_signer_with_capability(resource_cap);
        let name;
        if(id==0){
            name = string::utf8(b"Agent K9 #");
        }else if(id==1){
            name = string::utf8(b"Officer Katz #");
        }else if(id==2){
            name = string::utf8(b"Juvenile Punk #");
        }else if(id==3){
            name = string::utf8(b"Cyborg-Gunner #");
        }else if(id==4){
            name = string::utf8(b"Dragonkin Scout #");
        }else
            name = string::utf8(b"Princess Erato #");
        
        

        let token_constructor_ref  = token::create_numbered_token(
            resource_signer,
            string::utf8(CollectionName),
            string::utf8(CollectionDescription),
            name,
            string::utf8(b""),
            option::none(),
            string::utf8(TokenURI),
        );

        //auto set token's picture
        let uri = string::utf8(TokenURI);
        
        string::append(&mut uri, string_utils::to_string(&id));
        string::append(&mut uri, string::utf8(b".json"));
        let token_mutator_ref = token::generate_mutator_ref(&token_constructor_ref);
        token::set_uri(&token_mutator_ref, uri);

        let token_signer = object::generate_signer(&token_constructor_ref);
        

        move_to(&token_signer, TokenRef{
            burn_ref: token::generate_burn_ref(&token_constructor_ref),
            transfer_ref: object::generate_transfer_ref(&token_constructor_ref)
        } 
        );

        event::emit(
            MintEvent{
                owner: signer::address_of(sender),
                token: object::address_from_constructor_ref(&token_constructor_ref),
                content
            }
        );

        object::transfer(
            resource_signer,
            object::object_from_constructor_ref<Token>(&token_constructor_ref),
            signer::address_of(sender),
        );

        // update history
        let history = borrow_global_mut<History>(@seekers_galxe);
        table::upsert(&mut history.history, address_of(sender), id);
        let current_mint_amount = *table::borrow_with_default(&history.mint_amount, id, &0);
        table::upsert(&mut history.mint_amount, id, current_mint_amount + 1);
        // debug::print(&current_mint_amount);

        object::object_from_constructor_ref(&token_constructor_ref)

        
    }

    
    #[test(admin = @seekers_galxe, buyer = @0x2, seller = @0x3)]
    public fun test_mint(admin: &signer, buyer: &signer, seller: &signer) acquires ResourceCap, History {

        init_module(admin);

        mint_test(buyer, string::utf8(b"test mint"),0);
        let myToken = mint_test(seller, string::utf8(b"test mint"),0);
        /* burn(seller, myToken); */
        assert!(object::is_owner(myToken, address_of(seller)), 1);
        let name = token::name(myToken);
        let myToken = mint_test(admin, string::utf8(b"test mint"),1);

        assert!(object::is_owner(myToken, address_of(admin)), 1);


        // check mint amount
        let amount = get_mint_amount(0);
        assert!(amount == 2, 2);
        amount = get_mint_amount(1);
        assert!(amount == 1, 3);
        amount = get_mint_amount(2);
        assert!(amount == 0, 4);
        amount = get_mint_amount(3);
        assert!(amount == 0, 5);
    }
    #[test(admin = @seekers_galxe, buyer = @0x2, seller = @0x3)]
    public fun test_transfer(admin: &signer, buyer: &signer, seller: &signer) acquires ResourceCap, TokenRef, History {

        init_module(admin);

        let myToken = mint_test(buyer, string::utf8(b"test mint"),0);
        transfer(buyer, myToken, address_of(seller));
        assert!(object::is_owner(myToken, address_of(seller)), 1);
        let name = token::name(myToken);
    }
    #[test(admin = @seekers_galxe, buyer = @0x2, seller = @0x3)]
    #[expected_failure]
    public fun test_burn (admin: &signer, buyer: &signer, seller: &signer) acquires ResourceCap, TokenRef, History {

        init_module(admin);

        let myToken = mint_test(buyer, string::utf8(b"test mint"),0);
        burn(buyer, myToken);
        assert!(object::is_owner(myToken, address_of(buyer)), 1);
        let name = token::name(myToken);
    }
    // #[test(admin = @0x1, buyer = @0x2, seller = @0x3)]
    // #[expected_failure]
    // public fun test_repeated_mint(admin: &signer, buyer: &signer, seller: &signer) acquires ResourceCap, History {

    //     init_module(admin);

    //     mint(buyer, string::utf8(b"test mint"),0);
    //     mint(buyer, string::utf8(b"test mint"),0);
    // }

    #[test(admin = @seekers_galxe, buyer = @0x2, seller = @0x3)]
    #[expected_failure]
    public fun test_invalid_nft(admin: &signer, buyer: &signer, seller: &signer) acquires ResourceCap, History {

        init_module(admin);

        mint_test(buyer, string::utf8(b"test mint"),6);
    }
    

}