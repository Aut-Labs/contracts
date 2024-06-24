//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../hub-contracts/IHubDomainsRegistry.sol";
import "../hub-contracts/PublicResolver.sol";

interface INovaRegistry {
    function checkNova(address) external view returns (bool);

    function initialize(address autIdAddr_, address novaLogic, address pluginRegistry, address hubDomainsRegistry_) external;

    function deployNova(uint256 market, string memory metadata, uint256 commitment) external returns (address nova);

    function joinNovaHook(address user) external;

    function listUserNovas(address user) external view returns (address[] memory);

    function setAllowlistAddress(address) external;
}
