//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/// @title ICooldownOnbaordingPeriod
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
interface ICooldownOnbaordingPeriod {

    event CooldownPeriodSet();

    function getCooldownPeriod() external view returns(uint);
}
