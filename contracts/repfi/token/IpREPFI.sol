// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPREPFI is IERC20 {
    function burn(address account, uint256 value) external returns (bool);
}
