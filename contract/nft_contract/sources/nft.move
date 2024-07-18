module nft::nft{
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


    const RESOURCECAPSEED : vector<u8> = b"Seekers Alliance";

    const ENOT_TOKEN_OWNER: u64 = 1;

    const ALREADY_MINTED: u64 = 2;

    const NFT_NOT_FOUND: u64 = 3;

    const CollectionDescription: vector<u8> = b"Seekers Alliance NFTs";

    const CollectionName: vector<u8> = b"Seekers Alliance";

    const CollectionURI: vector<u8> = b"ipfs://QmWmgfYhDWjzVheQyV2TnpVXYnKR25oLWCB2i9JeBxsJbz";

    const TokenURI: vector<u8> = b"ipfs://bafybeiearr64ic2e7z5ypgdpu2waasqdrslhzjjm65hrsui2scqanau3ya/";


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
            history: table::new()
        };
        move_to(sender, history);

    }
    


    public entry fun mint(sender: &signer, content: string::String, id: u64) acquires ResourceCap, History {
        let minted = table::contains(&borrow_global<History>(@nft).history, address_of(sender));
        // TEST
        /* assert!(!minted, error::permission_denied(ALREADY_MINTED)); */
        assert!(id < 6, error::invalid_argument(NFT_NOT_FOUND));

        let resource_cap = &borrow_global<ResourceCap>(account::create_resource_address(
            &@nft, RESOURCECAPSEED
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

        table::upsert(&mut borrow_global_mut<History>(@nft).history, address_of(sender), id);

        /* object::object_from_constructor_ref(&token_constructor_ref) */
        
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

        let history = borrow_global<History>(@nft);
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


    
    #[test(admin = @0x1, buyer = @0x2, seller = @0x3)]
    public fun test_mint(admin: &signer, buyer: &signer, seller: &signer) acquires ResourceCap, History {

        init_module(admin);

        mint(buyer, string::utf8(b"test mint"),0);
        let myToken = mint(seller, string::utf8(b"test mint"),0);
        /* burn(seller, myToken); */
        assert!(object::is_owner(myToken, address_of(seller)), 1);
        let name = token::name(myToken);
        let myToken = mint(admin, string::utf8(b"test mint"),1);

        assert!(object::is_owner(myToken, address_of(admin)), 1);
    }
    #[test(admin = @0x1, buyer = @0x2, seller = @0x3)]
    public fun test_transfer(admin: &signer, buyer: &signer, seller: &signer) acquires ResourceCap, TokenRef, History {

        init_module(admin);

        let myToken = mint(buyer, string::utf8(b"test mint"),0);
        transfer(buyer, myToken, address_of(seller));
        assert!(object::is_owner(myToken, address_of(seller)), 1);
        let name = token::name(myToken);
    }
    #[test(admin = @0x1, buyer = @0x2, seller = @0x3)]
    #[expected_failure]
    public fun test_burn (admin: &signer, buyer: &signer, seller: &signer) acquires ResourceCap, TokenRef, History {

        init_module(admin);

        let myToken = mint(buyer, string::utf8(b"test mint"),0);
        burn(buyer, myToken);
        assert!(object::is_owner(myToken, address_of(buyer)), 1);
        let name = token::name(myToken);
    }
    #[test(admin = @0x1, buyer = @0x2, seller = @0x3)]
    #[expected_failure]
    public fun test_repeated_mint(admin: &signer, buyer: &signer, seller: &signer) acquires ResourceCap, History {

        init_module(admin);

        mint(buyer, string::utf8(b"test mint"),0);
        mint(buyer, string::utf8(b"test mint"),0);
    }

    #[test(admin = @0x1, buyer = @0x2, seller = @0x3)]
    #[expected_failure]
    public fun test_invalid_nft(admin: &signer, buyer: &signer, seller: &signer) acquires ResourceCap, History {

        init_module(admin);

        mint(buyer, string::utf8(b"test mint"),6);
    }
    

}