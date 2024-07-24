//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ReputationMining is OwnableUpgradeable {
    IERC20 public repFiToken;
    IERC20 public pRepFiToken;

    uint256 public constant MAX_MINT_PER_PERIOD = 1000; // to be changed later
    uint256 public period = 1;
    uint256 public lastPeriodChange = 0;
    uint256 public constant PERIOD_DURATION = 28 days;
    mapping(uint256 period => uint256 amount) private tokensLeft;
    mapping(address user => mapping(uint256 period => uint256 amount)) private givenBalance;

    function initialize(address initialOwner, address _repFiToken, address _pRepFiToken) external initializer {
        __Ownable_init(initialOwner);
        repFiToken = IERC20(_repFiToken);
        pRepFiToken = IERC20(_pRepFiToken);
    }

    uint256[50] private __gap;

    function updatePeriod() external onlyOwner {
        // check if it's allowed to update period
        require(block.timestamp - lastPeriodChange >= PERIOD_DURATION, "previous period has not ended yet");

        // ToDo: cleanup after last period
        // slashed or unused tokens from the last period should be burned or sent to the circular contract.
        pRepFiToken.transfer(address(0), tokensLeft[period]);
        // send repfi to circular contract?

        tokensLeft[period] = 0;

        period++;
        lastPeriodChange = block.timestamp;

        // initialize amount of tokens unlocked in this month
        tokensLeft[period] = this.getTokensForPeriod(period);
    }

    function claimUtilityToken() external {
        // ToDo: Distribute monthly pREPFI tokens based on formula

        // check autID

        // calculate allocation for this period

        // save the allocation amount for later use
        givenBalance[msg.sender][period] = 0;

        // send tokens
    }

    function claim() external {
        // ToDo: calculate how much of the pREPFI tokens the user has used in this period and distribute monthly allocation of REPFI tokens
        // user can only claim for last period?
        // check pREPFI balance vs allocated tokens for last period unless there's a better way to check this
        // calculate rewards based on token utilisation
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
