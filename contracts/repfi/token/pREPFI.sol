// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {IRepFiRegistry} from "../repFiRegistry/IRepFiRegistry.sol";

/// @title Predictive Reputation Finance token
/// @author Āut Labs
/// @notice Predictive Reputation Finance token with symbol pREPFI
contract PRepFi is ERC20, AccessControl {
    IRepFiRegistry repFiRegistry;

    bytes32 public constant BURNER_ROLE = keccak256("BURNER");

    /// @notice creates the Predictive Reputation Finance token (pREPFI), initializes the sender as the admin, configures the PrepFiRegistry contract, mints 100 million tokens to the sender
    /// @param _owner the owner of the contract
    /// @param _pluginRegistry the address of the plugin registry contract
    constructor(address _owner, address _pluginRegistry) ERC20("Predictive Reputation Finance", "pREPFI") {
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        repFiRegistry = IRepFiRegistry(_pluginRegistry);
        _mint(msg.sender, 100_000_000 ether);
    }

    /// @notice restricts the transfer between accounts and will fail when the sender is not a registered plugin in the RepFi registry
    /// @param to the address of the receiver
    /// @param value the amount of tokens to transfer
    /// @return bool whether the transfer was successful
    function transfer(address to, uint256 value) public override returns (bool) {
        require(repFiRegistry.isPlugin(_msgSender()), "Transfer not allowed");
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /// @notice restricts the transfer between accounts and will fail when the receiver is not a registered plugin in the RepFi registry
    /// @param from the address of the sender
    /// @param to the address of the receiver
    /// @param value the amount of tokens to transfer
    /// @return bool whether the transfer was successful
    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        require(repFiRegistry.isPlugin(to), "Transfer not allowed");
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /// @notice restricts the approval between accounts and will fail when the spender is not a registered plugin in the RepFi registry
    /// @param spender the address of the receiver
    /// @param value the amount of tokens to approve
    /// @return bool whether the approval was successful
    function approve(address spender, uint256 value) public override returns (bool) {
        require(repFiRegistry.isPlugin(spender), "Approve not allowed");
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /// @notice burn an amount of tokens for a given account, only callable by an address with the BURNER_ROLE
    /// @param account the address of the account to burn tokens from
    /// @param value the amount of tokens to transfer
    /// @return bool whether the transfer was successful
    function burn(address account, uint256 value) external onlyRole(BURNER_ROLE) returns (bool) {
        _burn(account, value);
        return true;
    }
}