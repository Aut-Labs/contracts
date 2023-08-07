//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMiniMeToken is IERC20 {}

/// @title IAragon
/// @notice The minimal interface of the Aragon contract needed for checking for a membership
interface IAragonKernel {}

interface IAragonApp {
    function token() external view returns (IMiniMeToken);
}
