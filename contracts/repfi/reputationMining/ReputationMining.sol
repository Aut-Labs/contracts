//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPREPFI} from "../token/IpREPFI.sol";
import {IReputationMining} from "./IReputationMining.sol";
import {IRandomNumberGenerator} from "../../randomNumberGenerator/IRandomNumberGenerator.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ReputationMining is ReentrancyGuard, OwnableUpgradeable, IReputationMining {
    IERC20 public repFiToken;
    IPREPFI public pRepFiToken;
    address public circular;
    IRandomNumberGenerator randomNumberGenerator;

    uint256 public constant MAX_MINT_PER_PERIOD = 100 ether; // to be changed later
    uint256 public constant DENOMINATOR = 1000;
    uint256 public period = 0;
    uint256 public lastPeriodChange = 0;
    uint256 public constant PERIOD_DURATION = 28 days;
    mapping(uint256 period => uint256 amount) public tokensLeft;
    mapping(address user => mapping(uint256 period => uint256 amount)) public givenBalance;

    using SafeERC20 for IERC20;
    using SafeERC20 for IPREPFI;

    function initialize(
        address initialOwner,
        address _repFiToken,
        address _pRepFiToken,
        address _circular,
        address _randomNumberGenerator
    ) external initializer {
        __Ownable_init(initialOwner);
        repFiToken = IERC20(_repFiToken);
        pRepFiToken = IPREPFI(_pRepFiToken);
        circular = _circular;
        randomNumberGenerator = IRandomNumberGenerator(_randomNumberGenerator);
    }

    uint256[50] private __gap;

    function updatePeriod() external onlyOwner {
        // check if it's allowed to update period
        require(
            (block.timestamp - lastPeriodChange >= PERIOD_DURATION) || (period == 0),
            "previous period has not ended yet"
        );

        period++;
        lastPeriodChange = block.timestamp;

        // initialize amount of tokens unlocked in this month
        tokensLeft[period] = this.getTokensForPeriod(period);

        // ToDo: cleanup after last period
        // slashed or unused tokens from the last period should be burned or sent to the circular contract.

        uint256 leftoverTokens = tokensLeft[period - 1];
        tokensLeft[period - 1] = 0;

        if (leftoverTokens > 0) {
            bool success = pRepFiToken.burn(address(this), leftoverTokens);
            require(success, "failed to burn tokens");
        }
    }

    function claimUtilityToken() external nonReentrant {
        require(givenBalance[msg.sender][period] == 0, "user already claimed pREPFI");

        uint256 pRepFiBalance = pRepFiToken.balanceOf(msg.sender);
        if (pRepFiBalance > 0) {
            // reset pRepFi token balance
            // or should we claim their previous rewards instead?
            bool success = pRepFiToken.burn(msg.sender, pRepFiBalance);
            require(success, "Failed to burn remaining tokens");

            // send RepFI tokens for this user to circlular contract?
        }

        uint256 amount = getClaimableUtilityTokenForPeriod(msg.sender, period);

        // save the allocation amount for later use
        givenBalance[msg.sender][period] = amount;

        // send tokens
        pRepFiToken.safeTransfer(msg.sender, amount);
    }

    function getClaimableUtilityTokenForPeriod(address _account, uint256 _period) public view returns (uint256 amount) {
        // get peer value
        uint256 peerValue = randomNumberGenerator.getRandomNumberForAccount(_account, 80, 160);
        uint256 totalTokensForPeriod = getTokensForPeriod(_period);
        uint256 totalPeerValue = randomNumberGenerator.getRandomNumberForAccount(_account, 80000, 160000); // let's assume we have 1000 users with a random between 80 and 160 in peer value

        amount = peerValue * (totalTokensForPeriod / totalPeerValue);

        // in case the amount is bigger than the maximum allowed per period, set the maximum
        if (amount > MAX_MINT_PER_PERIOD) {
            amount = MAX_MINT_PER_PERIOD;
        }
    }

    function claim() external nonReentrant {
        // ToDo: calculate how much of the pREPFI tokens the user has used in this period and distribute monthly allocation of REPFI tokens
        uint256 givenAmount = givenBalance[msg.sender][period - 1];
        require(givenAmount > 0, "no claims available for this period");
        uint256 pRepFiBalance = pRepFiToken.balanceOf(msg.sender);
        require(pRepFiBalance <= givenAmount, "pRepFi balance should be smaller or equal to the given balance");

        // set givenBalance for previous period to 0 so the user can't claim twice
        givenBalance[msg.sender][period - 1] = 0;

        // calculate rewards based on token utilisation
        // check pREPFI balance vs allocated tokens for last period unless there's a better way to check this
        uint256 tokensUsed = givenAmount - pRepFiBalance;
        // what do we do with the decimals here? Looks like we need to scale to receive a number other than 0
        uint256 participation = tokensUsed > 0 ? ((tokensUsed) * 100) / givenAmount : 0;
        uint256 earnedTokens = 0;

        if (participation >= 60) {
            earnedTokens = pRepFiBalance;
        } else {
            uint256 ratio = (tokensUsed * DENOMINATOR) / ((givenAmount * 60) / 100);
            earnedTokens = (ratio * pRepFiBalance) / DENOMINATOR;
        }
        // burn pRepFI tokens
        bool success = pRepFiToken.burn(msg.sender, pRepFiBalance);
        require(success, "Failed to burn remaining RepFi");

        // send repFi tokens
        repFiToken.safeTransfer(msg.sender, earnedTokens);
        // send remaining repFi tokens to circle contract (or burn)
        repFiToken.safeTransfer(circular, givenAmount - earnedTokens);
    }

    function getTokensForPeriod(uint256 _period) public pure returns (uint256) {
        if (_period > 0 && _period <= 24) {
            return 500000 ether;
        }
        if (_period > 24 && _period <= 48) {
            return 1000000 ether;
        }
        return 0;
    }
}
