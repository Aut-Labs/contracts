//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IHubRegistry {
    function checkNova(address) external view returns (bool);

    function deployNova(uint256 market, string memory metadata, uint256 commitment) external returns (address nova);

    function join(address nova, address member, uint256 role, uint8 commitment) external;

    function listUserNovas(address user) external view returns (address[] memory);

    function setAllowlistAddress(address) external;
}
