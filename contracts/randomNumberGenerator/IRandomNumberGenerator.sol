//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRandomNumberGenerator {
    function getRandomNumberForAccount(address account, uint256 min, uint256 max) external view returns (uint256);
}
