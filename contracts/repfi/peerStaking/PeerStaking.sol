// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ICAUT} from "../token/IcAUT.sol";
import {IReputationMining} from "../reputationMining/IReputationMining.sol";
import {IRandomNumberGenerator} from "../../randomNumberGenerator/IRandomNumberGenerator.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IPeerStaking} from "./IPeerStaking.sol";
import {IPeerValue} from "../PeerValue/IPeerValue.sol";

contract PeerStaking is ReentrancyGuard, OwnableUpgradeable, IPeerStaking {
    uint256 constant DENOMINATOR = 1000;
    /// @notice the Aut token contract
    IERC20 public autToken;
    /// @notice the c-aut token contract
    ICAUT public cAutToken;
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

    using SafeERC20 for IERC20;
    using SafeERC20 for ICAUT;

    /// @notice gap used as best practice for upgradeable contracts
    uint256[50] private __gap;

    /// @notice PeerStaking contract initializer
    /// @param initialOwner The initial owner of the contract
    /// @param _autToken the address of the Aut token contract
    /// @param _cAutToken the address of the c-aut token contract
    /// @param _circular the address of the circular contract
    /// @param _peerValue the address of the PeerValue contract
    /// @param _reputationMining the address of the reputation mining contract
    function initialize(
        address initialOwner,
        address _autToken,
        address _cAutToken,
        address _circular,
        address _peerValue,
        address _reputationMining
    ) external initializer {
        __Ownable_init(initialOwner);
        autToken = IERC20(_autToken);
        cAutToken = ICAUT(_cAutToken);
        circular = _circular;
        peerValue = IPeerValue(_peerValue);
        reputationMining = IReputationMining(_reputationMining);
    }

    /// @notice Enables users to stake their tokens and gamble on the future growth of an āut user.
    /// @param amount the amount of tokens to stake
    /// @param stakee the address of the user that we're tracking the growth of
    /// @param duration duration of the stake, in amount of periods
    /// @param estimatedGrowth the estimated growth percentage denomincated to 1000 => 100%
    function stake(
        uint256 amount,
        address stakee,
        uint256 duration,
        int256 estimatedGrowth
    ) external returns (uint256 stakeId) {
        require(amount > 0, "amount must be bigger than 0");
        require(stakee != address(0), "invalid staker");
        require(duration > 0, "duration is not long enough");
        require(estimatedGrowth > 0, "expected growth is too low"); // should be used with denominator, so 20% => 200

        // Stakes are possible only on stakees whose ĀutID is 5 periods or older
        uint256 age = peerValue.getAge(stakee);
        require(age >= 5, "stakee has been active for less than 5 periods");
        // limit period (D) of future growth prediction to be lower than or equal to the Age (A) of stakee’s ĀutID.
        require(age >= duration, "duration is longer than the stakee's age");

        // get current period
        uint256 currentPeriod = reputationMining.currentPeriod();
        // limit the stake to be equal to or lower than the monthly reward of the staker
        uint256 montlyRewardForStaker = reputationMining.getClaimableUtilityTokenForPeriod(msg.sender, currentPeriod);
        require(montlyRewardForStaker >= amount, "amount is higher than montly staker reward");

        // save the stake in storage
        Stake memory newStake = Stake(msg.sender, stakee, amount, currentPeriod, estimatedGrowth, duration, true);
        stakeId = totalStakes;

        stakes[stakeId] = newStake;

        totalStakes++;

        emit StakeAdded(stakeId, msg.sender, stakee, newStake);
        autToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    /// @notice Enables users to unstake the stake they have placed earlier. Funds are only claimable once the duration is past
    /// @param stakeId The stake ID which was returned after staking
    function unstake(uint256 stakeId) external {
        // get current period
        uint256 currentPeriod = reputationMining.currentPeriod();
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
        int256 actualGrowth = int256(((actualPeerValue - startPeerValue) * 100) / startPeerValue);

        uint256 age = peerValue.getAge(currentStake.stakee);
        (uint256 highestContinuousSegment, uint256 gLi) = peerValue.getGrowthLikelyhood(
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
        autToken.safeTransfer(msg.sender, earnedAmount);
    }
}
