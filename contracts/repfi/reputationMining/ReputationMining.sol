//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ICREPFI} from "../token/IcREPFI.sol";
import {IReputationMining} from "./IReputationMining.sol";
import {IRandomNumberGenerator} from "../../randomNumberGenerator/IRandomNumberGenerator.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title Reputation Mining
/// @author Āut Labs
/// @notice This contract distributes an allocation of cRepFi tokens to Āut users depending on their peer value every period
/// users can then utilize these tokens using the plugins defined in the UtilsRegistry contract. When the period has ended
/// the admin will update the period after which users can claim the RepFi tokens they have earned in the previous period
/// based on their usage and can receive new cRepFi tokens and put them to use in the next period.
contract ReputationMining is ReentrancyGuard, OwnableUpgradeable, IReputationMining {
    // event emitted when the period has updated
    event MiningStarted(uint256 indexed periodId, uint256 timestamp);
    // event emitted when utility tokens are claimed
    event UtilityTokensClaimed(
        uint256 indexed periodId,
        address indexed account,
        uint256 timestamp,
        uint256 givenBalance
    );
    // event emitted when repfi tokens are claimed
    event RewardTokensClaimed(
        uint256 indexed periodId,
        address indexed account,
        uint256 timestamp,
        uint256 amount,
        uint256 tokensBurned,
        uint256 tokensRecycled
    );

    /// @notice the RepFi token contract
    IERC20 public repFiToken;
    /// @notice the cRepFi token contract
    ICREPFI public cRepFiToken;
    /// @notice address where unclaimed funds will be sent to so they can be used by the platform
    address public circular;
    /// @notice random generator contract where we can get a random value for "peer value" as well was the "total value"
    /// @dev this contract will be replaced with the PeerValue contract in the near future, this is just for testing the functionality in the meantime
    IRandomNumberGenerator randomNumberGenerator;

    // @notice maximum amount of cRepFi tokens a user can receive each period
    uint256 public constant MAX_MINT_PER_PERIOD = 100 ether;
    // @notice lower bound of random number generator PeerValue
    uint256 private constant LOWER_BOUND_RANDOM_PEER_VALUE = 80;
    // @notice upper bound of random number generator PeerValue
    uint256 private constant UPPER_BOUND_RANDOM_PEER_VALUE = 160;
    // @notice lower bound of random number generator total PeerValue
    uint256 private constant LOWER_BOUND_RANDOM_TOTAL_PEER_VALUE = 80000;
    // @notice upper bound of random number generator total PeerValue
    uint256 private constant UPPER_BOUND_RANDOM_TOTAL_PEER_VALUE = 160000;
    // @notice first reputation mining threshold of 24 periods
    uint256 private constant FIRST_MINING_REWARD_DURATION_THRESHOLD = 24;
    // @notice second reputation mining threshold of 48 periods
    uint256 private constant SECOND_MINING_REWARD_DURATION_THRESHOLD = 48;
    // @notice percentage denominator
    uint256 constant PERCENTAGE_DENOMINATOR = 100;
    // @notice minimum participation score
    uint256 constant MIN_PARTICIPATION_SCORE = 60;
    // @notice reduced multiplier for lower participation score
    uint256 constant REDUCED_PARTICIPATION_SCORE_REWARD_PERCENTAGE = 60;
    // @notice amount of months to mine tokens
    uint256 constant TOTAL_AMOUNT_OF_MINING_IN_MONTHS = 48;
    // @notice the start of the first period
    uint256 public firstPeriodStart = 0;
    // @notice period duration
    uint256 public constant PERIOD_DURATION = 28 days;
    // @notice first period id
    uint256 public firstPeriodId = 1;
    // @notice mapping that saves how many tokens were left in every period, to make sure not more tokens are distributed than planned and this can also be used to
    // send the remaining tokens for each period to the circular contract
    mapping(uint256 period => uint256 amount) public tokensLeft;
    // @notice mapping with the givenBalance for each user for every period. This way we can check back later how many tokens the user has received for a certain period
    mapping(address user => mapping(uint256 period => uint256 amount)) public givenBalance;
    // @notice mapping to keep track of the periods that have been initialized
    mapping(uint256 period => bool initialized) public periodsInitialized;

    using SafeERC20 for IERC20;
    using SafeERC20 for ICREPFI;

    /// @notice ReputationMining contract initializer
    /// @param initialOwner The initial owner of the contract
    /// @param _repFiToken the address of the RepFi token contract
    /// @param _cRepFiToken the address of the cRepFi token contract
    /// @param _circular the address of the circular contract
    /// @param _randomNumberGenerator the address of the RandomNumberGenerator contract
    function initialize(
        address initialOwner,
        address _repFiToken,
        address _cRepFiToken,
        address _circular,
        address _randomNumberGenerator
    ) external initializer {
        require(
            _repFiToken != address(0) &&
                _cRepFiToken != address(0) &&
                _circular != address(0) &&
                _randomNumberGenerator != address(0),
            "zero address passed as parameter"
        );
        __Ownable_init(initialOwner);
        repFiToken = IERC20(_repFiToken);
        cRepFiToken = ICREPFI(_cRepFiToken);
        circular = _circular;
        randomNumberGenerator = IRandomNumberGenerator(_randomNumberGenerator);
    }

    /// @notice gap used as best practice for upgradeable contracts
    uint256[50] private __gap;

    // anyone can cleanup the previous periods, no access control needed
    function cleanupPeriod(uint256 _periodId) external {
        require(_periodId < currentPeriod(), "period has not ended yet");

        uint256 leftoverTokens = tokensLeft[_periodId];
        tokensLeft[_periodId] = 0;

        if (leftoverTokens > 0) {
            cRepFiToken.burn(address(this), leftoverTokens);
            repFiToken.transfer(address(circular), leftoverTokens);
        }
    }

    function activateMining() external onlyOwner {
        require(firstPeriodStart == 0, "already activated");
        firstPeriodStart = block.timestamp;

        // initialize tokensLeft mapping for each period
        for (uint256 i = firstPeriodId; i <= TOTAL_AMOUNT_OF_MINING_IN_MONTHS; i++) {
            tokensLeft[i] = getTokensForPeriod(i);
        }

        emit MiningStarted(currentPeriod(), firstPeriodStart);
    }

    /// @notice distributes cRepFi tokens to an Āut user once per period based on their peer value and save the givenBalance for later
    function claimUtilityToken() external nonReentrant {
        uint256 period = currentPeriod();
        require(period > 0, "mining has not started yet");

        //check if there's anything to claim from the previous period
        require(givenBalance[msg.sender][period - 1] == 0, "unclaimed rewards from previous period");

        require(givenBalance[msg.sender][period] == 0, "user already claimed cREPFI");

        uint256 cRepFiBalance = cRepFiToken.balanceOf(msg.sender);
        if (cRepFiBalance > 0) {
            // reset cRepFi token balance
            cRepFiToken.burn(msg.sender, cRepFiBalance);

            // send RepFI tokens for this user to circlular contract
            repFiToken.transfer(address(circular), cRepFiBalance);
        }

        uint256 amount = getClaimableUtilityTokenForPeriod(msg.sender, period);
        require(amount <= tokensLeft[period], "not enough tokens left to distribute for this period");

        emit UtilityTokensClaimed(period, msg.sender, block.timestamp, amount);

        // save the allocation amount for later use
        givenBalance[msg.sender][period] = amount;

        // send tokens
        cRepFiToken.safeTransfer(msg.sender, amount);
    }

    /// @notice calculates the claimable utility token for a given user in a given period
    /// @param _account the account for whom the tokens should be calculated
    /// @param _period the period for which to calculate the claimable utility tokens
    /// @dev we are using a random number for peerValue and totalPeerValue at the moment until we can use the PeerValue contract that is yet to be developed
    /// @return amount the claimable utility token for a given user in a given period
    function getClaimableUtilityTokenForPeriod(address _account, uint256 _period) public view returns (uint256 amount) {
        // get peer value
        uint256 peerValue = randomNumberGenerator.getRandomNumberForAccount(
            _account,
            LOWER_BOUND_RANDOM_PEER_VALUE,
            UPPER_BOUND_RANDOM_PEER_VALUE
        );
        uint256 totalTokensForPeriod = getTokensForPeriod(_period);
        uint256 totalPeerValue = randomNumberGenerator.getRandomNumberForAccount(
            _account,
            LOWER_BOUND_RANDOM_TOTAL_PEER_VALUE,
            UPPER_BOUND_RANDOM_TOTAL_PEER_VALUE
        ); // let's assume we have 1000 users with a random between 80 and 160 in peer value

        amount = peerValue * (totalTokensForPeriod / totalPeerValue);

        // in case the amount is bigger than the maximum allowed per period, set the maximum
        if (amount > MAX_MINT_PER_PERIOD) {
            amount = MAX_MINT_PER_PERIOD;
        }
    }

    /// @notice claims the reward tokens (RepFi) for the sender based on the utilisation of the cRepFi token in the previous period and transfers the remaining balance to the circular contract
    function claim() external nonReentrant {
        uint256 period = currentPeriod();
        require(period > 0, "mining has not started yet");

        // calculate how much of the cREPFI tokens the user has used in this period and distribute monthly allocation of REPFI tokens
        uint256 givenAmount = givenBalance[msg.sender][period - 1];
        require(givenAmount > 0, "no claims available for this period");
        uint256 cRepFiBalance = cRepFiToken.balanceOf(msg.sender);
        require(cRepFiBalance <= givenAmount, "cRepFi balance should be smaller or equal to the given balance");

        // set givenBalance for previous period to 0 so the user can't claim twice
        givenBalance[msg.sender][period - 1] = 0;

        // calculate rewards based on token utilisation
        // check cREPFI balance vs allocated tokens for last period unless there's a better way to check this
        uint256 tokensUsed = givenAmount - cRepFiBalance;
        uint256 participation = tokensUsed > 0 ? ((tokensUsed) * PERCENTAGE_DENOMINATOR) / givenAmount : 0;
        uint256 earnedTokens = 0;

        if (participation >= MIN_PARTICIPATION_SCORE) {
            earnedTokens = cRepFiBalance;
        } else {
            earnedTokens =
                (cRepFiBalance * tokensUsed * PERCENTAGE_DENOMINATOR) /
                (givenAmount * REDUCED_PARTICIPATION_SCORE_REWARD_PERCENTAGE);
        }

        emit RewardTokensClaimed(
            period,
            msg.sender,
            block.timestamp,
            earnedTokens,
            cRepFiBalance,
            givenAmount - earnedTokens
        );

        // burn cRepFi tokens
        cRepFiToken.burn(msg.sender, cRepFiBalance);

        // send repFi tokens
        repFiToken.safeTransfer(msg.sender, earnedTokens);
        // send remaining repFi tokens to circle contract
        repFiToken.safeTransfer(circular, givenAmount - earnedTokens);
    }

    /// @notice returns the amount of tokens that will be distributed within a given period
    /// @param _period the period in which we want to know the tokens that are being distributed
    /// @return the amount of tokens that will be distributed within a given period
    function getTokensForPeriod(uint256 _period) public pure returns (uint256) {
        // 500000 tokens for the first 2 years
        if (_period > 0 && _period <= FIRST_MINING_REWARD_DURATION_THRESHOLD) {
            return 500000 ether;
        }
        // 1000000 tokens for years 3 and 4
        if (_period > FIRST_MINING_REWARD_DURATION_THRESHOLD && _period <= SECOND_MINING_REWARD_DURATION_THRESHOLD) {
            return 1000000 ether;
        }
        return 0;
    }

    function currentPeriod() public view returns (uint256) {
        if (firstPeriodStart == 0) {
            // mining has not been activated yet
            return 0;
        }

        return ((block.timestamp - firstPeriodStart) / PERIOD_DURATION) + 1;
    }
}