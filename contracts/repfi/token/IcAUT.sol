// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface ICAUT is IERC1155 {
    function getTokensForPeriod(uint256 period) external pure returns(uint256);
    function burn(address account, uint256 id, uint256 value) external returns (bool);
}
