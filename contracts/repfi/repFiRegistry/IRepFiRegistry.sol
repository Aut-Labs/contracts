//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRepFiRegistry {
    function initialize(address) external;

    function registerPlugin(address) external;

    function removePlugin(address) external;

    function isPlugin(address) external view returns (bool);
}
