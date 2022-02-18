%lang starknet
%builtins pedersen range_check

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import (Uint256)
from starkware.starknet.common.messages import send_message_to_l1
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_not_zero

####################
# STRUCTS
####################

struct FactRecord:
    member fact : Uint256
    member is_valid : felt
end

####################
# STORAGE VARIABLES
####################

@storage_var
func counter() -> (count: felt):
end

@storage_var
func l1_contract_address() -> (addr: felt):
end

@storage_var
func fact_registry(fact_low_bits: felt, fact_high_bits: felt) -> (fact: FactRecord):
end

####################
# CONSTRUCTOR
####################

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(l1_addr: felt):
    _init_counter()

    l1_contract_address.write(l1_addr)

    return ()
end

####################
# INTERNAL FUNCTIONS
####################

func _init_counter{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}():
    counter.write(0)

    return ()
end

func _increment{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (count: felt):
    let (count) = counter.read()
    counter.write(count + 1)

    let (new_count) = counter.read()

    return (count=new_count)
end

####################
# GETTER FUNCTIONS
####################

@view
func get_l1_address{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (addr: felt):
    let (l1_address) = l1_contract_address.read()

    return (l1_address)
end

@view
func get_fact_check{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(fact_low: felt, fact_high: felt) -> (fact: FactRecord):
    let (fact: FactRecord) = fact_registry.read(fact_low, fact_high)

    return (fact)
end

@view
func get_total_recieved{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (cow: felt):
    let (count) = counter.read()
    return (count)
end

####################
# EXTERNAL FUNCTIONS
####################

@external
func fact_check_sharp{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(fact: Uint256) -> ():
    let (l1_address) = l1_contract_address.read()
    
    let (message_payload: felt*) = alloc()
    assert message_payload[0] = fact.low
    assert message_payload[1] = fact.high

    send_message_to_l1(
        to_address=l1_address,
        payload_size=2,
        payload=message_payload)

    return ()
end

@l1_handler
func ship_sharp_stark{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(from_address: felt, fact_low: felt, fact_high: felt, is_valid: felt):
    _increment()
    let (l1_address) = l1_contract_address.read()
    assert from_address = l1_address
    
    let fact = Uint256(low=fact_low, high=fact_high)
    fact_registry.write(fact_low, fact_high, FactRecord(fact, is_valid))

    return ()
end

@external
func update_l1_address{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(new_address: felt) -> ():
    # Only_Owner()
    l1_contract_address.write(new_address)

    return ()
end

# @external
# func transfer_contract_ownership{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(new_owner: felt) -> (owner: felt):
#     Only_Owner()
#     let (owner) = Transfer_Ownable_Ownership(new_owner)

#     return (owner)
# end