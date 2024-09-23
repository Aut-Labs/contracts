//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IOnboarding {
    function isOnboarded(address who, uint256 role) external view returns (bool);
}

interface IRoleOnboarding {
    function isOnboarded(address who) external view returns (bool);
}
