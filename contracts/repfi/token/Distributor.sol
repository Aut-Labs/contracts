// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Initial Distribution
/// @author Āut Labs
/// @notice takes care of the initial distribution of the Aut token
contract Distributor {
    // event triggered when tokens are distributed
    event TokensDistributed(address indexed receiver, address token, uint256 amount, uint256 timestamp);

    /// @notice one million tokens
    uint256 public constant MILLION_ETHER = 1000000 ether;

    /// @notice owner of the contract
    address public immutable owner;
    /// @notice aut token contract
    IERC20 public immutable aut;
    // IERC20 public immutable c-aut;

    /// sales multisig
    address public immutable sales;
    /// @notice Reputation Mining contract
    address public immutable reputationMining;
    /// @notice airdrop merkle contract
    address public immutable airdrop;
    /// @notice investors token vesting contract
    address public immutable investors;
    /// @notice team token vesting contract
    address public immutable team;
    /// @notice  partners multisig contract
    address public immutable partners;
    /// @notice  ecosystem multisig contract
    address public immutable ecosystem;

    /// @notice creates a new initial distribution contract
    /// @param _aut Aut token address
    /// @param _sales sales multisig
    /// @param _reputationMining reputation mining contract
    /// @param _airdrop merkle contract
    /// @param _investors TokenVesting contract for investors
    /// @param _team TokenVesting contract for team
    /// @param _partners multisig contract for partners
    /// @param _ecosystem multisig contract for ecosystem
    constructor(
        IERC20 _aut,
        address _sales,
        address _reputationMining,
        address _airdrop,
        address _investors,
        address _team,
        address _partners,
        address _ecosystem
    ) {
        require(
            address(_aut) != address(0) &&
                _sales != address(0) &&
                _reputationMining != address(0) &&
                _airdrop != address(0) &&
                _investors != address(0) &&
                _team != address(0) &&
                _partners != address(0) &&
                _ecosystem != address(0),
            "zero address passed as parameter"
        );
        owner = msg.sender;
        aut = _aut;

        sales = _sales;
        reputationMining = _reputationMining;
        airdrop = _airdrop;
        investors = _investors;
        team = _team;
        partners = _partners;
        ecosystem = _ecosystem;
    }

    /// @notice distributes the Aut tokens to the different contracts using predifined amounts
    function distribute() external {
        require(msg.sender == owner, "only owner can distribute");
        require(aut.balanceOf(address(this)) == 100 * MILLION_ETHER, "not enough Aut in the contract for distribution");

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

    /// @notice sends Aut tokens to the receiver
    /// @param receiver the receiver of the tokens
    /// @param amount the amount of tokens to be transferred
    function sendTokens(address receiver, uint256 amount) internal {
        aut.transfer(receiver, amount);
        emit TokensDistributed(receiver, address(aut), amount, block.timestamp);
    }
}
