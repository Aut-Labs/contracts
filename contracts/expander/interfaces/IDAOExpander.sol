//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IDAOExpanderInteractions.sol";
import "./IDAOExpanderAdmin.sol";
import "./IDAOExpanderData.sol";
import "./IDAOExpanderURL.sol";
import "./IDAOExpanderMembership.sol";

/// @title IDAOExpander
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOExpander is IDAOExpanderAdmin, IDAOExpanderData, IDAOExpanderInteractions, IDAOExpanderMembership, IDAOExpanderURL { }