// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPeerStaking {
    struct Stake {
        address staker;
        address stakee;
        uint256 amount;
        uint256 timestamp;
        int256 estimatedGrowth;
        uint256 duration;
        bool active;
    }

    function initialize(
        address initialOwner,
        address _autToken,
        address _cAutToken,
        address _circular,
        address _randomNumberGenerator,
        address _reputationMining
    ) external;

    function stake(
        uint256 amount,
        address stakee,
        uint256 duration,
        int256 expectedGrowth
    ) external returns (uint256 stakeId);

    function unstake(uint256 stakeId) external;
}
