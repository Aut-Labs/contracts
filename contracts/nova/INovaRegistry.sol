// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INovaRegistry {
    function checkNova(address) external view returns(bool);

    function initialize(address autIdAddr_, address novaLogic, address pluginRegistry) external;

    function deployNova(uint256 market, string memory metadata, uint256 commitment) external returns(address nova);
}
