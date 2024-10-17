// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title Reputation Finance token
/// @author Āut Labs
/// @notice Reputation Finance token with symbol REPFI
contract RepFi is ERC20 {
    /// @notice creates the Reputation Finance token (REPFI) and mints 100 million tokens to the sender
    constructor() ERC20("Aut Labs", "REPFI") {
        _mint(msg.sender, 100_000_000 ether);
    }
}
