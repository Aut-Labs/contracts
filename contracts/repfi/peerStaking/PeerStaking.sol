// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPREPFI} from "../token/IpREPFI.sol";
import {IReputationMining} from "../reputationMining/IReputationMining.sol";
import {IRandomNumberGenerator} from "../../randomNumberGenerator/IRandomNumberGenerator.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IPeerStaking} from "./IPeerStaking.sol";
import {IPeerValue} from "../PeerValue/IPeerValue.sol";

contract PeerStaking is ReentrancyGuard, OwnableUpgradeable, IPeerStaking {
    uint256 constant DENOMINATOR = 1000;
    /// @notice the RepFi token contract
    IERC20 public repFiToken;
    /// @notice the pRepFi token contract
    IPREPFI public pRepFiToken;
    /// @notice address where unclaimed funds will be sent to so they can be used by the platform
    address public circular;
    /// @notice random generator contract where we can get a random value for "peer value" as well was the "total value"
    /// @dev this contract will be replaced with the PeerValue contract in the near future, this is just for testing the functionality in the meantime
    IPeerValue peerValue;

    IReputationMining public reputationMining;

    uint256 public totalStakes;

    mapping(uint256 stakeId => Stake stake) private stakes;

    event StakeAdded(uint256 indexed stakeId, address indexed staker, address indexed stakee, Stake stake);

    event StakeClaimed(
        uint256 indexed stakeId,
        address indexed staker,
        address indexed stakee,
        Stake stake,
        uint256 rewardAmount
    );

    struct Stake {
        address staker;
        address stakee;
        uint256 amount;
        uint256 timestamp;
        // ToDo: perhaps it makes more sense to use int so we can also use negative numbers?
        uint256 estimatedGrowth;
        uint256 duration;
        bool active;
    }

    using SafeERC20 for IERC20;
    using SafeERC20 for IPREPFI;

    /// @notice gap used as best practice for upgradeable contracts
    uint256[50] private __gap;

    /// @notice PeerStaking contract initializer
    /// @param initialOwner The initial owner of the contract
    /// @param _repFiToken the address of the RepFi token contract
    /// @param _pRepFiToken the address of the pRepFi token contract
    /// @param _circular the address of the circular contract
    /// @param _peerValue the address of the PeerValue contract
    /// @param _reputationMining the address of the reputation mining contract
    function initialize(
        address initialOwner,
        address _repFiToken,
        address _pRepFiToken,
        address _circular,
        address _peerValue,
        address _reputationMining
    ) external initializer {
        __Ownable_init(initialOwner);
        repFiToken = IERC20(_repFiToken);
        pRepFiToken = IPREPFI(_pRepFiToken);
        circular = _circular;
        peerValue = IPeerValue(_peerValue);
        reputationMining = IReputationMining(_reputationMining);
    }

    function stake(
        uint256 amount,
        address stakee,
        uint256 duration,
        uint256 estimatedGrowth
    ) external returns (uint256 stakeId) {
        require(amount > 0, "amount must be bigger than 0");
        require(stakee != address(0), "invalid staker");
        require(duration > 0, "duration is not long enough");
        require(estimatedGrowth > 0, "expected growth is too low");

        // Stakes are possible only on stakees whose ĀutID is 5 periods or older
        uint256 age = peerValue.getAge(stakee);
        require(age >= 5, "stakee has been active for less than 5 periods");
        // limit period (D) of future growth prediction to be lower than or equal to the Age (A) of stakee’s ĀutID.
        require(age >= duration, "duration is longer than the stakee's age");

        // get current period
        uint256 currentPeriod = reputationMining.period();
        // limit the stake to be equal to or lower than the monthly reward of the staker
        uint256 montlyRewardForStaker = reputationMining.getClaimableUtilityTokenForPeriod(msg.sender, currentPeriod);
        require(montlyRewardForStaker >= amount, "amount is higher than montly staker reward");

        // save the stake in storage
        Stake memory newStake = Stake(msg.sender, stakee, amount, currentPeriod, estimatedGrowth, duration, true);
        stakeId = totalStakes;

        stakes[stakeId] = newStake;

        totalStakes++;

        emit StakeAdded(stakeId, msg.sender, stakee, newStake);
        repFiToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    function unstake(uint256 stakeId) external {
        // get current period
        uint256 currentPeriod = reputationMining.period();
        // check if the stake exists
        Stake storage currentStake = stakes[stakeId];
        require(currentStake.amount > 0, "Stake not found");
        require(currentStake.active, "stake is not active");
        require(currentStake.staker == msg.sender, "msg.sender is not the owner of the stake");
        // make sure the duration has passed
        require(currentStake.timestamp + currentStake.duration >= currentPeriod, "stake is still ongoing");
        // check the stakee's global reputation and compare with the bet that was placed and reward or slash the staking reward depending on the outcome, using a random number for now
        uint256 earnedAmount = 0;

        uint256 startPeerValue = peerValue.getPeerValue(currentStake.stakee, currentStake.timestamp);
        require(startPeerValue > 0, "start peer value does not exist for user");
        uint256 actualPeerValue = peerValue.getPeerValue(currentStake.stakee, currentPeriod);
        require(actualPeerValue > 0, "Actual peer value does not exist for user");
        uint256 actualGrowth = (actualPeerValue * DENOMINATOR) / startPeerValue;

        uint256 age = peerValue.getAge(currentStake.stakee);
        (uint256 segments, uint256 highestContinuousSegment, uint256 fDgj, uint256 gLi) = peerValue.getGrowthLikelyhood(
            currentStake.stakee,
            currentStake.estimatedGrowth,
            currentStake.duration
        );

        if (currentStake.estimatedGrowth >= actualGrowth) {
            // staker's prediction was correct, thus will be rewarded
            if (highestContinuousSegment == 0) {
                earnedAmount = (currentStake.amount * 1500) / DENOMINATOR;
            } else {
                earnedAmount =
                    (currentStake.amount * (DENOMINATOR + gLi + ((currentStake.duration * DENOMINATOR) / age))) /
                    DENOMINATOR;
            }
        } else {
            // staker's prediction was wrong thus the staked amount will be slashed
            if (highestContinuousSegment == 0) {
                earnedAmount = (currentStake.amount * 750) / DENOMINATOR;
            } else {
                earnedAmount =
                    (currentStake.amount * (DENOMINATOR - gLi + ((currentStake.duration * DENOMINATOR) / age))) /
                    DENOMINATOR;
            }
        }

        // set active to false
        currentStake.active = false;
        emit StakeClaimed(stakeId, msg.sender, currentStake.stakee, currentStake, earnedAmount);
        repFiToken.safeTransfer(msg.sender, earnedAmount);
    }
}
