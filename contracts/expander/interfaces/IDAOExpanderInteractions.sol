//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IDAOExpander
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOExpanderInteractions {

    function getInteractionsAddr() external view returns (address);

    function getInteractionsPerUser(address member)
        external
        view
        returns (uint256);

}
