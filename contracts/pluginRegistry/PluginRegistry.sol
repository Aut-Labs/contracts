//SDPX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract PluginRegistry is OwnableUpgradeable {
    function initialize(address initialOwner) external initializer {
        __Ownable_init(initialOwner);
    }

    uint256[50] private __gap;
}
