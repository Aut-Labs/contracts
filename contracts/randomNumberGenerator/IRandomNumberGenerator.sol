//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRandomNumberGenerator {
    function getRandomNumberForAccount(address account, uint256 min, uint256 max) external view returns (uint256);

    function getRandomPeerValueParametersForAccount(
        address account,
        uint256 minPS,
        uint256 maxPS,
        uint256 minP,
        uint256 maxP,
        uint256 minARing,
        uint256 maxARing
    ) external view returns (uint256 participationScore, uint256 prestige, uint256 a_ring);
}
