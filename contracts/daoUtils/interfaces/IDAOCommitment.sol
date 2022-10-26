//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IDAOMetadata
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOCommitment {

    event CommitmentSet();

    function getCommitment() external view returns(uint commitment);
    
    function setCommitment(uint commitment) external;

}
