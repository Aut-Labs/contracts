//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IRandomNumberGenerator.sol";

contract RandomNumberGenerator is IRandomNumberGenerator {
    // uint256 nonce = 0;

    function getRandomNumberForAccount(address account, uint256 min, uint256 max) external view returns (uint256) {
        uint randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, account))) % (max - min); // choices in this range
        randomnumber = randomnumber + min; // add min to get our start of the range
        return randomnumber;
    }
}
