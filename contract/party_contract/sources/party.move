module party::party{
    use std::signer;
    use std::signer::address_of;
    use std::string;
    use std::debug;
    use std::error;
    use aptos_std::table;
    use aptos_std::table::Table;
    use aptos_framework::account;
    use aptos_framework::account::SignerCapability;
    use aptos_framework::event;
    
    const ALREADY_PARTICIPATED: u64 = 1;
    const FACTION_NOT_FOUND: u64 = 2;

    const RESOURCECAPSEED : vector<u8> = b"Seekers Alliance";

    struct ResourceCap has key {
        cap: SignerCapability
    }

    struct Content has key {
        content: string::String
    }

    struct Factions has key {
        faction: Table<address, u64>,
        player_name: Table<address, string::String>,
        faction_counter: Table<u64, u64>
    }

    #[event]
    struct ParticipateEvent has drop, store {
        owner: address,
        faction_id: u64,
    }
    #[event]
    struct UpdatePlayerNameEvent has drop, store {
        owner: address,
        name: string::String
    }


    fun init_module(sender: &signer) {
        let (resource_signer, resource_cap) = account::create_resource_account(
            sender, RESOURCECAPSEED
        );

        move_to(&resource_signer, ResourceCap{ cap:resource_cap });
        
        let factions = Factions{
            faction: table::new(),
            player_name: table::new(),
            faction_counter: table::new()
        };
        move_to(sender, factions);

    }
    public entry fun participate(sender: &signer, faction_id: u64) acquires Factions {
        assert!(faction_id > 0 && faction_id < 4, error::invalid_argument(FACTION_NOT_FOUND));

        let factions = borrow_global_mut<Factions>(@party);
        // TEST
        /* assert!(table::contains(&factions.faction, address_of(sender))==false, error::permission_denied(ALREADY_PARTICIPATED)); */
        table::upsert(&mut factions.faction, address_of(sender), faction_id);
        let counter = *table::borrow_with_default(&factions.faction_counter, faction_id, &0);
        table::upsert(&mut factions.faction_counter, faction_id, counter+1);
        
        event::emit(
            ParticipateEvent{
                owner: signer::address_of(sender),
                faction_id
            }
        );

    }
    public entry fun update_player_name(sender: &signer, name: string::String) acquires Factions {
        let factions = borrow_global_mut<Factions>(@party);
        table::upsert(&mut factions.player_name, address_of(sender), name);

        event::emit(
            UpdatePlayerNameEvent{
                owner: signer::address_of(sender),
                name
            }
        );
    }


    #[view]
    public fun get_faction(sender: address):string::String acquires Factions {

        let factions = borrow_global<Factions>(@party);
        let fraction_id:u64 = *table::borrow_with_default(&factions.faction, sender, &0);
        if(fraction_id == 1){
            return string::utf8(b"VAN DER LECK FAMILY")
        }else if(fraction_id == 2){
            return string::utf8(b"HOUSE GALAHAD")
        }else if(fraction_id == 3){
            return string::utf8(b"MAHDIA ALLIANCE")
        }else{
            return string::utf8(b"NOT FOUND")
        }
    }
    #[view]
    public fun get_faction_counter(faction_id: u64):u64 acquires Factions {

        let factions = borrow_global<Factions>(@party);
        let nft_id:u64 = *table::borrow_with_default(&factions.faction_counter, faction_id, &0);
        nft_id
    }
    #[view]
    public fun get_player_name(sender: address):string::String acquires Factions {

        let factions = borrow_global<Factions>(@party);
        let name = *table::borrow_with_default(&factions.player_name, sender, &string::utf8(b"NOT FOUND"));
        name
    }
    #[view]
    public fun check_player_enroll_name(sender: address):bool acquires Factions {

        let factions = borrow_global<Factions>(@party);
        table::contains(&factions.player_name, sender)
    }

    
    #[test(admin = @0x2, buyer = @0x3, seller = @0x4)]
    public fun test_participate(admin: &signer, buyer: &signer, seller: &signer) acquires Factions {
            
            init_module(admin);
            participate(buyer, 2);
            participate(seller, 2);
            let faction  = get_faction(address_of(seller));
            debug::print(&faction);
            assert!(faction == 2, 2);
            let counter = get_faction_counter(faction);
            debug::print(&counter);
            assert!(counter == 2, 3);
    }
    /* test repeated participation */
    #[test(admin = @0x2, buyer = @0x3, seller = @0x4)]
    #[expected_failure]
    public fun test_participate_repeated(admin: &signer, buyer: &signer, seller: &signer) acquires Factions {
            
            init_module(admin);
            participate(seller, 2);
            participate(seller, 2);
            
    }
    /* test invalid faction */
    #[test(admin = @0x2, buyer = @0x3, seller = @0x4)]
    #[expected_failure]
    public fun test_participate_invalid_faction(admin: &signer, buyer: &signer, seller: &signer) acquires Factions {
            
            init_module(admin);
            participate(seller, 4);
            
    }
    #[test(admin = @0x2, buyer = @0x3, seller = @0x4)]
    public fun test_update_player_name(admin: &signer, buyer: &signer, seller: &signer) acquires Factions {
            
            init_module(admin);
            update_player_name(buyer, string::utf8(b"K9"));
            let name = get_player_name(address_of(buyer));
            assert!(name == string::utf8(b"K9"), 1);
            let name = get_player_name(address_of(seller));
            assert!(name == string::utf8(b"NOT FOUND"), 2);
            assert!(check_player_enroll_name(address_of(buyer)), 3);
            assert!(check_player_enroll_name(address_of(seller))==false, 4);
    }
    
    


}