// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import {IRepFiRegistry} from "../repFiRegistry/IRepFiRegistry.sol";

contract PRepFi is ERC20, AccessControl {
    IRepFiRegistry repFiRegistry;

    bytes32 public constant BURNER_ROLE = keccak256("BURNER");

    constructor(address _owner, address _pluginRegistry) ERC20("Predictive Reputation Finance", "pREPFI") {
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        repFiRegistry = IRepFiRegistry(_pluginRegistry);
        _mint(msg.sender, 100_000_000 ether);
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        require(repFiRegistry.isPlugin(_msgSender()), "Transfer not allowed");
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        require(repFiRegistry.isPlugin(to), "Transfer not allowed");
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        require(repFiRegistry.isPlugin(spender), "Approve not allowed");
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    function burn(address account, uint256 value) external onlyRole(BURNER_ROLE) returns (bool) {
        _burn(account, value);
        return true;
    }
}
