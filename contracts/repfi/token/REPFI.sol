// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract REPFI is ERC20 {
    constructor() ERC20("Reputation Finance", "REPFI") {
        _mint(msg.sender, 100_000_000 * 10e18);
    }
}
