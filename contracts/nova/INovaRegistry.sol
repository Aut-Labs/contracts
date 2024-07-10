//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INovaRegistry {
    function checkNova(address) external view returns (bool);

    function initialize(address autIdAddr_, address novaLogic, address pluginRegistry, address hubDomainsRegistry) external;

    function deployNova(uint256 market, string memory metadata, uint256 commitment) external returns (address nova);

    function joinNovaHook(address user) external;

    function listUserNovas(address user) external view returns (address[] memory);

    function setAllowlistAddress(address) external;

    function registerDomain(string calldata domain, address novaAddress, string calldata metadataUri) external;

    function getDomain(string calldata domain) external view returns (address, string memory);
}
