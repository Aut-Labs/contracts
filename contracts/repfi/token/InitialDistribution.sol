// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {TokenVesting} from "../vesting/TokenVesting.sol";
import {IReputationMining} from "../reputationMining/IReputationMining.sol";

// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract InitialDistribution {
    using SafeERC20 for IERC20;

    uint256 public constant MILLION_ETHER = 1000000 ether;

    address public immutable owner;
    IERC20 public immutable repFi;
    // IERC20 public immutable pRepFi;

    TokenVesting public immutable privateSale;
    TokenVesting public immutable community;
    IReputationMining public immutable reputationMining;
    address public immutable airdrop; // merkle?
    TokenVesting public immutable investors;
    TokenVesting public immutable team;
    address public immutable partners; // multisig
    address public immutable ecosystem; // multisig

    constructor(
        IERC20 _repFi,
        // IERC20 _pRepFi,
        TokenVesting _privateSale,
        TokenVesting _community,
        IReputationMining _reputationMining,
        address _airdrop,
        TokenVesting _investors,
        TokenVesting _team,
        address _partners,
        address _ecosystem
    ) {
        owner = msg.sender;
        repFi = _repFi;
        // pRepFi = _pRepFi;

        privateSale = _privateSale;
        community = _community;
        reputationMining = _reputationMining;
        airdrop = _airdrop;
        investors = _investors;
        team = _team;
        partners = _partners;
        ecosystem = _ecosystem;
    }

    function distribute() external {
        require(msg.sender == owner, "only owner can distribute");
        require(repFi.balanceOf(address(this)) == 100 * MILLION_ETHER, "RepFI has already been sent from the contract");

        // 8 million for private sale
        sendTokens(address(privateSale), 8 * MILLION_ETHER);

        // 7 million for public sale
        sendTokens(address(community), 7 * MILLION_ETHER);

        // 36 million for reputation mining
        sendTokens(address(reputationMining), 36 * MILLION_ETHER);

        // 4 million for airdrop
        sendTokens(address(airdrop), 4 * MILLION_ETHER);

        // 10 million for founder and investors
        sendTokens(address(investors), 10 * MILLION_ETHER);

        // 5 million for team and contributors
        sendTokens(address(team), 5 * MILLION_ETHER);

        // 15 million for partners and listing
        sendTokens(address(partners), 15 * MILLION_ETHER);

        // 15 million for ecosystem fund
        sendTokens(address(ecosystem), 15 * MILLION_ETHER);
    }

    function sendTokens(address receiver, uint256 amount) internal {
        repFi.safeTransfer(receiver, amount);
        // // ToDo: this contract should be added to the plugin registry, otherwise the transfer will fail
        // pRepFi.safeTransfer(receiver, amount);
    }
}
