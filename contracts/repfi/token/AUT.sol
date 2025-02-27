// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title Aut Labs token
/// @author Āut Labs
/// @notice Aut token with symbol AUT
contract Aut is ERC20 {
    /// @notice creates the Aut Labs token (AUT) and mints 100 million tokens to the sender
    constructor() ERC20("Aut Labs", "AUT") {
        _mint(msg.sender, 100_000_000 ether);
    }
}
