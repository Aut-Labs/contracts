// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LocalReputationProxy is Proxy, Ownable {
    bytes32 private constant _IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("id.aut.os.autid.proxy.implementation")) - 1);

    constructor(address implementation_) Ownable() {
        upgrade(implementation_);
    }

    function implementation() external view returns (address) {
        return _implementation();
    }

    function upgrade(address to) public onlyOwner {
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = to;
    }

    function _implementation() internal view override returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }
}
