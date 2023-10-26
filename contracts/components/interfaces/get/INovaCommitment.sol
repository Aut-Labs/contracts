//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title INova
/// @notice The interface for the extension of each DAO that integrates AutID
interface INovaCommitment {
    function getCommitment() external view returns (uint256 commitment);
}
