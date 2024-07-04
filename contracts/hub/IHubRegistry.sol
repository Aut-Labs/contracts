//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../hubContracts/IHubDomainsRegistry.sol";

interface IHubRegistry {
    function checkHub(address) external view returns (bool);

    function initialize(address autIdAddr_, address hubLogic, address pluginRegistry, address hubDomainsRegistry) external;

    function deployHub(uint256 market, string memory metadata, uint256 commitment) external returns (address hub);

    function joinHubHook(address user) external;

    function listUserHubs(address user) external view returns (address[] memory);

    function setAllowlistAddress(address) external;
}
