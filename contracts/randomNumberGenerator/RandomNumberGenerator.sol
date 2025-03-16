//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./IRandomNumberGenerator.sol";

contract RandomNumberGenerator is IRandomNumberGenerator {
    function getRandomNumberForAccount(address account, uint256 min, uint256 max) external view returns (uint256) {
        uint randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, account))) % (max - min); // choices in this range
        randomnumber += min; // add min to get our start of the range
        return randomnumber;
    }

    function getRandomPeerValueParametersForAccount(
        address account,
        uint256 minPS,
        uint256 maxPS,
        uint256 minP,
        uint256 maxP,
        uint256 minARing,
        uint256 maxARing
    ) external view returns (uint256 participationScore, uint256 prestige, uint256 a_ring) {
        uint nonce = 1;
        participationScore = uint(keccak256(abi.encodePacked(block.timestamp, account, nonce))) % (maxPS - minPS); // choices in this range
        participationScore += minPS; // add min to get our start of the range

        nonce++;

        prestige = uint(keccak256(abi.encodePacked(block.timestamp, account, nonce))) % (maxP - minP);
        prestige += minP;

        nonce++;

        a_ring = uint(keccak256(abi.encodePacked(block.timestamp, account, nonce))) % (maxARing - minARing);
        a_ring += minARing;

        return (participationScore, prestige, a_ring);
    }
}
