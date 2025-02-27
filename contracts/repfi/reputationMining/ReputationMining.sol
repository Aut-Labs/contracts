//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ICAUT} from "../token/IcAUT.sol";
import {IReputationMining} from "./IReputationMining.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IPeerValue} from "../peerValue/IPeerValue.sol";
import {IAutID} from "../../autid/autid.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Reputation Mining
/// @author Āut Labs
/// @notice This contract distributes an allocation of c-aut tokens to Āut users depending on their peer value every period
/// users can then utilize these tokens using the plugins defined in the UtilsRegistry contract. When the period has ended
/// the admin will update the period after which users can claim the Aut tokens they have earned in the previous period
/// based on their usage and can receive new c-aut tokens and put them to use in the next period.
contract ReputationMining is ReentrancyGuard, OwnableUpgradeable, IReputationMining, ERC1155Holder {
    // event emitted when the period has updated
    event MiningStarted(uint256 indexed periodId, uint256 timestamp);
    // event emitted when c-tokens are claimed
    event CTokensClaimed(
        uint256 indexed periodId,
        uint256 indexed autId,
        address indexed account,
        uint256 timestamp,
        uint256 givenBalance
    );
    // event emitted when aut tokens are claimed
    event RewardTokensClaimed(
        uint256 indexed periodId,
        uint256 indexed autId,
        address indexed account,
        uint256 timestamp,
        uint256 amount,
        uint256 tokensBurned,
        uint256 tokensRecycled
    );

    /// @notice the Aut token contract
    IERC20 public autToken;
    /// @notice the c-aut token contract
    ICAUT public cAutToken;
    /// @notice address where unclaimed funds will be sent to so they can be used by the platform
    address public circular;
    /// @notice random generator contract where we can get a random value for "peer value" as well was the "total value"
    /// @dev this contract will be replaced with the PeerValue contract in the near future, this is just for testing the functionality in the meantime
    IPeerValue peerValue;
    /// @notice the autId contract
    IAutID public autId;

    // @notice maximum amount of c-aut tokens a user can receive each period
    uint256 public constant MAX_MINT_PER_PERIOD = 100 ether;
    // @notice first reputation mining threshold of 24 periods
    uint256 private constant FIRST_MINING_REWARD_DURATION_THRESHOLD = 24;
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
    // @notice mapping with the givenBalance for each user for every period. This way we can check back later how many tokens the user has received for a certain period
    mapping(address user => mapping(uint256 period => uint256 amount)) public givenBalance;
    // @notice mapping to keep track of the periods that have been initialized
    mapping(uint256 period => bool initialized) public periodsInitialized;
    // @notice mapping to keep track of the periods claimed by a user
    mapping(address user => mapping(uint256 period => bool claimed)) public periodsClaimedByUser;

    using SafeERC20 for IERC20;
    using SafeERC20 for ICAUT;

    modifier onlyAutUser() {
        require(autId.tokenIdForAccount(msg.sender) != 0, "not an Aut user");
        _;
    }

    /// @notice ReputationMining contract initializer
    /// @param initialOwner The initial owner of the contract
    /// @param _autToken the address of the Aut token contract
    /// @param _cAutToken the address of the c-aut token contract
    /// @param _circular the address of the circular contract
    /// @param _peerValue the address of the RandomNumberGenerator contract
    function initialize(
        address initialOwner,
        address _autToken,
        address _cAutToken,
        address _circular,
        address _peerValue,
        address _autId
    ) external initializer {
        require(
            _autToken != address(0) &&
                _cAutToken != address(0) &&
                _circular != address(0) &&
                _peerValue != address(0) &&
                _autId != address(0),
            "zero address passed as parameter"
        );
        __Ownable_init(initialOwner);
        autToken = IERC20(_autToken);
        cAutToken = ICAUT(_cAutToken);
        circular = _circular;
        peerValue = IPeerValue(_peerValue);
        autId = IAutID(_autId);
    }

    /// @notice gap used as best practice for upgradeable contracts
    uint256[50] private __gap;

    /// @notice burns the leftover cAutToken and transfer the leftover AutToken to the circular contract
    /// @param _periodId the id of the period to clean up
    /// @dev anyone can cleanup the previous periods, no access control needed
    // @todo check if we really need nonReentrant here. It should offer additional security in case the function gets called by a malicious contract because of ERC1155 checks
    function cleanupPeriod(uint256 _periodId) external nonReentrant {
        require(_periodId < currentPeriod(), "period has not ended yet");

        uint256 leftoverTokens = cAutToken.balanceOf(address(this), _periodId);

        if (leftoverTokens > 0) {
            cAutToken.burn(address(this), _periodId, leftoverTokens);
            autToken.transfer(address(circular), leftoverTokens);
        }
    }

    /// @notice sets the first period and activates the mining mechanism of the contract
    function activateMining() external onlyOwner {
        require(firstPeriodStart == 0, "already activated");
        firstPeriodStart = block.timestamp;

        emit MiningStarted(currentPeriod(), firstPeriodStart);
    }

    /// @notice distributes c-aut tokens to an Āut user once per period based on their peer value and save the givenBalance for later
    function claimCToken() external nonReentrant onlyAutUser {
        uint256 period = currentPeriod();
        require(period > 0, "mining has not started yet");

        require(givenBalance[msg.sender][period] == 0, "user already claimed c-aut");

        uint256 cAutBalance = cAutToken.balanceOf(msg.sender, period - 1);
        if (cAutBalance > 0) {
            // reset c-aut token balance
            cAutToken.burn(msg.sender, period - 1, cAutBalance);

            // send Aut tokens for this user to circlular contract
            autToken.transfer(address(circular), cAutBalance);
        }

        uint256 amount = getClaimableCTokenForPeriod(msg.sender, period);
        require(
            amount <= cAutToken.balanceOf(address(this), period),
            "not enough tokens left to distribute for this period"
        );

        // save the allocation amount for later use
        givenBalance[msg.sender][period] = amount;

        // send tokens
        cAutToken.safeTransferFrom(address(this), msg.sender, period, amount, "");

        emit CTokensClaimed(period, autId.tokenIdForAccount(msg.sender), msg.sender, block.timestamp, amount);
    }

    /// @notice calculates the claimable c-token for a given user in a given period
    /// @param _account the account for whom the tokens should be calculated
    /// @param _period the period for which to calculate the claimable c-tokens
    /// @dev we are using a random number for peerValue and totalPeerValue at the moment until we can use the PeerValue contract that is yet to be developed
    /// @return amount the claimable c-token for a given user in a given period
    function getClaimableCTokenForPeriod(address _account, uint256 _period) public returns (uint256 amount) {
        // get peer value
        uint256 value = peerValue.getPeerValue(_account, _period);
        uint256 totalTokensForPeriod = cAutToken.getTokensForPeriod(_period);
        uint256 totalPeerValue = peerValue.getTotalPeerValue(_period);

        amount = (value * totalTokensForPeriod) / totalPeerValue;

        // in case the amount is bigger than the maximum allowed per period, set the maximum
        if (amount > MAX_MINT_PER_PERIOD) {
            amount = MAX_MINT_PER_PERIOD;
        }
    }

    /// @notice claims the reward tokens (Aut) for the sender based on the utilisation of the c-aut token in a specific period and transfers the remaining balance to the circular contract
    /// @param period the period ID of the period for which to claim
    function claimPeriod(uint256 period) public nonReentrant onlyAutUser {
        require(currentPeriod() > 0, "mining has not started yet");
        require(period < currentPeriod(), "period has not ended yet");
        require(periodsClaimedByUser[msg.sender][period] == false, "period already claimed by user");
        _claimPeriod(period);
    }

    /// @notice claims the reward tokens (Aut) for the sender based on the utilisation of the c-aut token in all periods and transfers the remaining balance to the circular contract
    // @todo check if this function doesn't run out of gas when claiming all periods at once
    function claimAllPeriods() public nonReentrant onlyAutUser {
        uint256 activePeriod = currentPeriod();
        require(activePeriod > 0, "mining has not started yet");

        // check if currentPeriod is higher than 48, if it is only loop to 48 and otherwise use the currentPeriod -1 as the last one
        uint256 lastPeriodToCheck = activePeriod > 48 ? 48 : activePeriod - 1;

        for (uint256 i; i <= lastPeriodToCheck; i++) {
            if (periodsClaimedByUser[msg.sender][i] == false && givenBalance[msg.sender][i] > 0) {
                _claimPeriod(i);
            }
        }
    }

    function _claimPeriod(uint256 period) internal {
        // calculate how much of the c-aut tokens the user has used in this period and distribute monthly allocation of AUT tokens
        uint256 givenAmount = givenBalance[msg.sender][period];
        require(givenAmount > 0, "no claims available for this period");
        uint256 cAutBalance = cAutToken.balanceOf(msg.sender, period);
        require(cAutBalance <= givenAmount, "c-aut balance should be smaller or equal to the given balance");

        // calculate rewards based on token utilisation
        // check c-aut balance vs allocated tokens for last period unless there's a better way to check this
        uint256 tokensUsed = givenAmount - cAutBalance;
        uint256 participation = tokensUsed > 0 ? ((tokensUsed) * PERCENTAGE_DENOMINATOR) / givenAmount : 0;
        uint256 earnedTokens = 0;

        if (participation >= MIN_PARTICIPATION_SCORE) {
            earnedTokens = cAutBalance;
        } else {
            earnedTokens =
                (cAutBalance * tokensUsed * PERCENTAGE_DENOMINATOR) /
                (givenAmount * REDUCED_PARTICIPATION_SCORE_REWARD_PERCENTAGE);
        }

        // save that the user has already claimed tokens for this period
        periodsClaimedByUser[msg.sender][period] == true;

        // burn c-aut tokens
        cAutToken.burn(msg.sender, period, cAutBalance);

        // send aut tokens
        autToken.safeTransfer(msg.sender, earnedTokens);
        // send remaining aut tokens to circle contract
        autToken.safeTransfer(circular, givenAmount - earnedTokens);

        emit RewardTokensClaimed(
            period,
            autId.tokenIdForAccount(msg.sender),
            msg.sender,
            block.timestamp,
            earnedTokens,
            cAutBalance,
            givenAmount - earnedTokens
        );
    }

    /// @notice calculates the current (active) period
    /// @return the current period ID or 0 if mining hasn't been activated
    function currentPeriod() public view returns (uint256) {
        if (firstPeriodStart == 0) {
            // mining has not been activated yet
            return 0;
        }

        return ((block.timestamp - firstPeriodStart) / PERIOD_DURATION) + 1;
    }
}
