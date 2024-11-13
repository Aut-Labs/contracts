// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {IUtilsRegistry} from "../utilsRegistry/IUtilsRegistry.sol";

/// @title Conditional Reputation Finance token
/// @author Āut Labs
/// @notice Conditional Reputation Finance token with symbol cREPFI
contract CRepFi is ERC20, AccessControl {
    IUtilsRegistry immutable utilsRegistry;

    bytes32 public constant BURNER_ROLE = keccak256("BURNER");

    /// @notice creates the Conditional Reputation Finance token (cREPFI), initializes the sender as the admin, configures the UtilsRegistry contract, mints 100 million tokens to the sender
    /// @param _owner the owner of the contract
    /// @param _utilsRegistry the address of the plugin registry contract
    constructor(address _owner, address _utilsRegistry) ERC20("Conditional REPFI", "cREPFI") {
        require(_owner != address(0) && _utilsRegistry != address(0), "zero address passed as parameter");
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        utilsRegistry = IUtilsRegistry(_utilsRegistry);
        _mint(_owner, 100000000 ether);
    }

    /// @notice restricts the transfer between accounts and will fail when the sender is not a registered plugin in the utils registry
    /// @param to the address of the receiver
    /// @param value the amount of tokens to transfer
    /// @return bool whether the transfer was successful
    function transfer(address to, uint256 value) public override returns (bool) {
        require(utilsRegistry.isPlugin(_msgSender()), "Transfer not allowed");
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /// @notice restricts the transfer between accounts and will fail when the receiver is not a registered plugin in the utils registry
    /// @param from the address of the sender
    /// @param to the address of the receiver
    /// @param value the amount of tokens to transfer
    /// @return bool whether the transfer was successful
    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        require(utilsRegistry.isPlugin(to), "Transfer not allowed");
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /// @notice restricts the approval between accounts and will fail when the spender is not a registered plugin in the utils registry
    /// @param spender the address of the receiver
    /// @param value the amount of tokens to approve
    /// @return bool whether the approval was successful
    function approve(address spender, uint256 value) public override returns (bool) {
        require(utilsRegistry.isPlugin(spender), "Approve not allowed");
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
