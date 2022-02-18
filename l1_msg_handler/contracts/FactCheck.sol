// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IStarknetCore.sol";

interface IFactRegistry {
    /*
      Returns true if the given fact was previously registered in the contract.
    */
    function isValid(bytes32 fact)
        external view
        returns(bool);
}

contract FactCheck {
    // The StarkNet core contract.
    IStarknetCore public starknetCore;
    IFactRegistry public factRegistry;

    // "ship_sharp_stark"
    uint256 constant SHIP_SHARP_STARK_SELECTOR =
        539011610878139872534487813156563666346610742897224119585232598785025604651;

    // GOERLI statement verifier
    address constant SHARP_VERIFIER_ADDRESS = 
        0x5EF3C980Bf970FcE5BbC217835743ea9f0388f4F;

    /**
      Initializes the contract state.
    */
    constructor(address _starknetCore) {
        starknetCore = IStarknetCore(_starknetCore);
        factRegistry = IFactRegistry(SHARP_VERIFIER_ADDRESS);
    }

    /**
      Util
    */
    function fmtFactStark(bytes32 fact) internal pure returns(uint256, uint256) {
        bytes16[2] memory felt = [bytes16(0), 0];
        assembly {
            mstore(felt, fact)
            mstore(add(felt, 16), fact)
        }

        return (uint256(uint128(felt[1])), (uint256(uint128(felt[0]))));
    }
    function concat (bytes16 a, bytes16 b) public pure returns (bytes32) {
        return bytes32 (uint256 (uint128 (a)) << 128 | uint128 (b));
    }

    /**
      Internals
    */
    function _proxyIsValid(
        bytes32 fact
    ) internal view returns(bool) {        
        return IFactRegistry(SHARP_VERIFIER_ADDRESS).isValid(fact);
    }

    function _shipSharpStark(
        uint256 l2ContractAddress,
        bytes32 fact
    ) internal {
        bool is_valid = _proxyIsValid(fact);

        require(is_valid == true, "fact is not true");

        (uint256 low, uint256 high) = fmtFactStark(fact);

        uint256[] memory payload = new uint256[](3);
        payload[0] = low;
        payload[1] = high;
        payload[2] = 1;

        starknetCore.sendMessageToL2(l2ContractAddress, SHIP_SHARP_STARK_SELECTOR, payload);
    }

    /**
      Externals
    */
    function getStarknetCore() external view returns(address) {
        return address(starknetCore);
    }
    
    function fact_check_sharp(
        uint256 l2ContractAddress,
        uint128 factLow,
        uint128 factHigh
    ) external {
        uint256[] memory payload = new uint256[](2);
        payload[0] = factLow;
        payload[1] = factHigh;

        starknetCore.consumeMessageFromL2(l2ContractAddress, payload);

        _shipSharpStark(l2ContractAddress, concat(bytes16(factHigh), bytes16(factLow)));
    }
    function proxyIsValid(
        bytes32 fact
    ) external view returns(bool) {        
        return factRegistry.isValid(fact);
    }

    event ShipSharpStark(
        uint256 indexed l2ContractAddress,
        bytes32 indexed fact,
        bool is_valid
    );

    function shipSharpStark(
        uint256 l2ContractAddress,
        bytes32 fact
    ) external {
        bool is_valid = _proxyIsValid(fact);

        require(is_valid == true, "fact is not true");

        (uint256 low, uint256 high) = fmtFactStark(fact);

        uint256[] memory payload = new uint256[](2);
        payload[0] = low;
        payload[1] = high;

        starknetCore.sendMessageToL2(l2ContractAddress, SHIP_SHARP_STARK_SELECTOR, payload);
    }
}