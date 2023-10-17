// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/utils/StorageSlot.sol";
import "../interfaces/INova.sol";

abstract contract ComponentBase {
    // 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50
    bytes32 private constant _BEACON_SLOT = bytes32(uint256(keccak256("eip1967.proxy.beacon")));
    bytes32 private constant _IMPLEMENTATION_SLOT =
        bytes32(uint256(keccak256("id.aut.os.proxy.implementation")) - 1);
    bytes32 private constant _NOVA_SLOT = bytes32("id.aut.os.proxy.nova");

    modifier novaCall {
        require(msg.sender == address(nova()));
        _;
    }

    function nova() public view returns (INova) {
        return INova(StorageSlot.getAddressSlot(_NOVA_SLOT).value);
    }

    function _getNovaSlot() internal pure returns (StorageSlot.AddressSlot storage) {
        return StorageSlot.getAddressSlot(_NOVA_SLOT);
    }

    function _getImplementationSlot() internal pure returns (StorageSlot.AddressSlot storage) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT);
    }

    function _getBeaconSlot() internal pure returns (StorageSlot.AddressSlot storage) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT);
    }

    uint256[50] private __gap;
}
