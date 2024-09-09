// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPeerStaking {
    function initialize(
        address initialOwner,
        address _repFiToken,
        address _pRepFiToken,
        address _circular,
        address _randomNumberGenerator,
        address _reputationMining
    ) external;

    function stake(
        uint256 amount,
        address stakee,
        uint256 duration,
        uint256 expectedGrowth
    ) external returns (uint256 stakeId);

    function unstake(uint256 stakeId) external;
}
