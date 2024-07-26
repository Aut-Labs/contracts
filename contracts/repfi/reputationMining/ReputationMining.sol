//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IPREPFI} from "../token/IpREPFI.sol";

// import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ReputationMining is ReentrancyGuard, OwnableUpgradeable {
    IERC20 public repFiToken;
    IPREPFI public pRepFiToken;
    address public circular;

    uint256 public constant MAX_MINT_PER_PERIOD = 1000; // to be changed later
    uint256 public period = 1;
    uint256 public lastPeriodChange = 0;
    uint256 public constant PERIOD_DURATION = 28 days;
    mapping(uint256 period => uint256 amount) private tokensLeft;
    mapping(address user => mapping(uint256 period => uint256 amount)) private givenBalance;

    function initialize(
        address initialOwner,
        address _repFiToken,
        address _pRepFiToken,
        address _circular
    ) external initializer {
        __Ownable_init(initialOwner);
        repFiToken = IERC20(_repFiToken);
        pRepFiToken = IPREPFI(_pRepFiToken);
        circular = _circular;
    }

    uint256[50] private __gap;

    function updatePeriod() external onlyOwner {
        // check if it's allowed to update period
        require(block.timestamp - lastPeriodChange >= PERIOD_DURATION, "previous period has not ended yet");

        tokensLeft[period] = 0;

        period++;
        lastPeriodChange = block.timestamp;

        // initialize amount of tokens unlocked in this month
        tokensLeft[period] = this.getTokensForPeriod(period);

        // ToDo: cleanup after last period
        // slashed or unused tokens from the last period should be burned or sent to the circular contract.
        pRepFiToken.burn(address(this), tokensLeft[period - 1]);
    }

    function claimUtilityToken() external nonReentrant {
        require(givenBalance[msg.sender][period] == 0, "user already claimed pREPFI");

        uint256 pRepFiBalance = pRepFiToken.balanceOf(msg.sender);
        if (pRepFiBalance > 0) {
            // reset pRepFi token balance
            pRepFiToken.burn(msg.sender, pRepFiBalance);

            // send RepFI tokens for this user to circlular contract?
        }

        // ToDo: get peer value (TBA)

        // calculate allocation for this period
        // ToDo: Distribute monthly pREPFI tokens based on formula
        uint256 amount = 0;
        // save the allocation amount for later use

        givenBalance[msg.sender][period] = amount;

        // send tokens
        pRepFiToken.transfer(msg.sender, amount);
    }

    function claim() external nonReentrant {
        // ToDo: calculate how much of the pREPFI tokens the user has used in this period and distribute monthly allocation of REPFI tokens
        uint256 givenAmount = givenBalance[msg.sender][period - 1];
        require(givenAmount > 0, "no claims available for this period");
        uint256 pRepFiBalance = pRepFiToken.balanceOf(msg.sender);
        require(pRepFiBalance < givenAmount, "pRepFi balance should be smaller than given balance");

        // set givenBalance for previous period to 0 so the user can't claim twice
        givenBalance[msg.sender][period - 1] = 0;

        // calculate rewards based on token utilisation
        // check pREPFI balance vs allocated tokens for last period unless there's a better way to check this
        uint256 tokensUsed = givenAmount - pRepFiBalance;
        uint256 participation = tokensUsed > 0 ? (tokensUsed / givenAmount) * 100 : 0;
        uint256 earnedTokens = 0;

        if (participation >= 60) {
            earnedTokens = givenAmount;
        } else {
            earnedTokens = tokensUsed / ((givenAmount * 60) / 100);
        }
        // burn pRepFI tokens
        pRepFiToken.burn(msg.sender, pRepFiBalance);

        // send repFi tokens
        bool earnedTokensSent = repFiToken.transfer(msg.sender, earnedTokens);
        require(earnedTokensSent, "Token transfer failed");
        // send remaining repFi tokens to circle contract (or burn)
        bool circularTokensSent = repFiToken.transfer(circular, givenAmount - earnedTokens);
        require(circularTokensSent, "Circular Token transfer failed");
    }

    function getTokensForPeriod(uint256 _period) external pure returns (uint256) {
        if (_period > 0 && _period <= 24) {
            return 1_000_000 * 10e18;
        }
        if (_period > 24 && _period <= 48) {
            return 2_000_000 * 10e18;
        }
        return 0;
    }
}
