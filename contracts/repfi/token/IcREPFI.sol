// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ICREPFI is IERC20 {
    function burn(address account, uint256 value) external returns (bool);
}
