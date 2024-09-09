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

contract PeerStaking is ReentrancyGuard, OwnableUpgradeable, IPeerStaking {
    /// @notice the RepFi token contract
    IERC20 public repFiToken;
    /// @notice the pRepFi token contract
    IPREPFI public pRepFiToken;
    /// @notice address where unclaimed funds will be sent to so they can be used by the platform
    address public circular;
    /// @notice random generator contract where we can get a random value for "peer value" as well was the "total value"
    /// @dev this contract will be replaced with the PeerValue contract in the near future, this is just for testing the functionality in the meantime
    IRandomNumberGenerator randomNumberGenerator;

    IReputationMining public reputationMining;

    struct Stake {
        uint256 stakeId;
        address staker;
        address stakee;
        uint256 amount;
        uint256 timestamp;
        uint256 estimatedGlobalReputation;
        uint256 duration;
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
    /// @param _randomNumberGenerator the address of the RandomNumberGenerator contract
    /// @param _reputationMining the address of the reputation mining contract
    function initialize(
        address initialOwner,
        address _repFiToken,
        address _pRepFiToken,
        address _circular,
        address _randomNumberGenerator,
        address _reputationMining
    ) external initializer {
        __Ownable_init(initialOwner);
        repFiToken = IERC20(_repFiToken);
        pRepFiToken = IPREPFI(_pRepFiToken);
        circular = _circular;
        randomNumberGenerator = IRandomNumberGenerator(_randomNumberGenerator);
        reputationMining = IReputationMining(_reputationMining);
    }

    function stake(
        uint256 amount,
        address stakee,
        uint256 duration,
        uint256 expectedGrowth
    ) external returns (uint256 stakeId) {
        // get current period
        uint256 currentPeriod = reputationMining.period();
        //ToDo: Investments are possible only on stakees whose ĀutID is 5 periods or older
        //ToDo: limit period (D) of future growth prediction to be lower than or equal to the Age (A) of stakee’s ĀutID.
        // limit the stake to be equal to or lower than the monthly reward of the staker
        uint256 montlyRewardForStaker = reputationMining.getClaimableUtilityTokenForPeriod(msg.sender, currentPeriod);
        require(montlyRewardForStaker >= amount, "amount is higher than montly staker reward");
        //ToDo: put a check to make sure the msg.sender is not the stakee? I don't think it's worth it as there are other ways to do it beyond our control

        // save the stake in storage

        repFiToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    function unstake(uint256 stakeId) external {
        // ToDo: make sure the duration has passed
        // ToDo: check the stakee's global reputation and compare with the bet that was placed
        // ToDo: reward or slash the staker depending on the outcome
        uint256 earnedAmount = 0;
        repFiToken.safeTransfer(msg.sender, earnedAmount);
    }
}
