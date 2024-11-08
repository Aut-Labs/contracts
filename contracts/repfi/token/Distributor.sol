// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {TokenVesting} from "../vesting/TokenVesting.sol";
import {IReputationMining} from "../reputationMining/IReputationMining.sol";

/// @title Initial Distribution
/// @author Āut Labs
/// @notice takes care of the initial distribution of the RepFi token
contract Distributor {
    using SafeERC20 for IERC20;

    /// @notice one million tokens
    uint256 public constant MILLION_ETHER = 1000000 ether;

    /// @notice owner of the contract
    address public immutable owner;
    /// @notice repFi token contract
    IERC20 public immutable repFi;
    // IERC20 public immutable cRepFi;

    /// sales multisig
    address public immutable sales;
    /// @notice Reputation Mining contract
    IReputationMining public immutable reputationMining;
    /// @notice airdrop merkle contract
    address public immutable airdrop;
    /// @notice investors token vesting contract
    TokenVesting public immutable investors;
    /// @notice team token vesting contract
    TokenVesting public immutable team;
    /// @notice  partners multisig contract
    address public immutable partners;
    /// @notice  ecosystem multisig contract
    address public immutable ecosystem;

    /// @notice creates a new initial distribution contract
    /// @param _repFi RepFi token address
    /// @param _sales sales multisig
    /// @param _reputationMining reputation mining contract
    /// @param _airdrop merkle contract
    /// @param _investors TokenVesting contract for investors
    /// @param _team TokenVesting contract for team
    /// @param _partners multisig contract for partners
    /// @param _ecosystem multisig contract for ecosystem
    constructor(
        IERC20 _repFi,
        // IERC20 _pRepFi,
        address _sales,
        IReputationMining _reputationMining,
        address _airdrop,
        TokenVesting _investors,
        TokenVesting _team,
        address _partners,
        address _ecosystem
    ) {
        owner = msg.sender;
        repFi = _repFi;

        sales = _sales;
        reputationMining = _reputationMining;
        airdrop = _airdrop;
        investors = _investors;
        team = _team;
        partners = _partners;
        ecosystem = _ecosystem;
    }

    /// @notice distributes the RepFi tokens to the different contracts using predifined amounts
    function distribute() external {
        require(msg.sender == owner, "only owner can distribute");
        require(
            repFi.balanceOf(address(this)) == 100 * MILLION_ETHER,
            "not enough RepFI in the contract for distribution"
        );

        // 15 million for token sales
        sendTokens(address(sales), 15 * MILLION_ETHER);

        // 36 million for reputation mining
        sendTokens(address(reputationMining), 36 * MILLION_ETHER);

        // 4 million for airdrop
        sendTokens(address(airdrop), 4 * MILLION_ETHER);

        // 10 million for founder and investors
        sendTokens(address(investors), 10 * MILLION_ETHER);

        // 5 million for team and contributors
        sendTokens(address(team), 5 * MILLION_ETHER);

        // 10 million for partners and listing
        sendTokens(address(partners), 10 * MILLION_ETHER);

        // 20 million for ecosystem fund
        sendTokens(address(ecosystem), 20 * MILLION_ETHER);
    }

    /// @notice sends RepFi tokens to the receiver
    /// @param receiver the receiver of the tokens
    /// @param amount the amount of tokens to be transferred
    function sendTokens(address receiver, uint256 amount) internal {
        repFi.safeTransfer(receiver, amount);
    }
}
