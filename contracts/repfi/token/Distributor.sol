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

    /// sale multisig
    address public immutable sale;
    /// @notice Reputation Mining contract
    address public immutable reputationMining;
    /// @notice airdrop merkle contract
    address public immutable airdrop;
    /// @notice founderInvestors token vesting contract
    address public immutable founderInvestors;
    /// @notice earlyContributors token vesting contract
    address public immutable earlyContributors;
    /// @notice listing and market makers multisig contract
    address public immutable listing;
    /// @notice  treasury multisig contract
    address public immutable treasury;
    /// @notice kolsAdvisors multisig contract
    address public kolsAdvisors;

    /// @notice creates a new initial distribution contract
    /// @param _aut Aut token address
    /// @param _sale sale multisig
    /// @param _reputationMining reputation mining contract
    /// @param _airdrop merkle contract
    /// @param _founderInvestors TokenVesting contract for founderInvestors
    /// @param _earlyContributors TokenVesting contract for earlyContributors
    /// @param _listing multisig contract for partners
    /// @param _treasury multisig contract for treasury
    constructor(
        IERC20 _aut,
        address _sale,
        address _reputationMining,
        address _airdrop,
        address _founderInvestors,
        address _earlyContributors,
        address _listing,
        address _treasury,
        address _kolsAdvisors
    ) {
        require(
            address(_aut) != address(0) &&
                _sale != address(0) &&
                _reputationMining != address(0) &&
                _airdrop != address(0) &&
                _founderInvestors != address(0) &&
                _earlyContributors != address(0) &&
                _listing != address(0) &&
                _treasury != address(0) &&
                _kolsAdvisors != address(0),
            "zero address passed as parameter"
        );
        owner = msg.sender;
        aut = _aut;

        sale = _sale;
        reputationMining = _reputationMining;
        airdrop = _airdrop;
        founderInvestors = _founderInvestors;
        earlyContributors = _earlyContributors;
        listing = _listing;
        treasury = _treasury;
        kolsAdvisors = _kolsAdvisors;
    }

    /// @notice distributes the Aut tokens to the different contracts using predifined amounts
    function distribute() external {
        require(msg.sender == owner, "only owner can distribute");
        require(aut.balanceOf(address(this)) == 100 * MILLION_ETHER, "not enough Aut in the contract for distribution");

        //7 million for token sale
        sendTokens(address(sale), 7 * MILLION_ETHER);

        // 36 million for reputation mining
        sendTokens(address(reputationMining), 36 * MILLION_ETHER);

        // 4 million for airdrop
        sendTokens(address(airdrop), 4 * MILLION_ETHER);

        // 10 million for founder and founderInvestors
        sendTokens(address(founderInvestors), 10 * MILLION_ETHER);

        // 5 million for earlyContributors and contributors
        sendTokens(address(earlyContributors), 5 * MILLION_ETHER);

        // 8 million for partners and listing
        sendTokens(address(listing), 8 * MILLION_ETHER);

        // 25 million for treasury fund
        sendTokens(address(treasury), 25 * MILLION_ETHER);

        // 5 million for kolsAdvisors fund
        sendTokens(address(kolsAdvisors), 5 * MILLION_ETHER);
    }

    /// @notice sends Aut tokens to the receiver
    /// @param receiver the receiver of the tokens
    /// @param amount the amount of tokens to be transferred
    function sendTokens(address receiver, uint256 amount) internal {
        aut.transfer(receiver, amount);
        emit TokensDistributed(receiver, address(aut), amount, block.timestamp);
    }
}
