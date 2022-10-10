//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../../daoUtils/interfaces/IDAOAdmin.sol";
import "../../daoUtils/interfaces/IDAOURL.sol";
import "../../daoUtils/interfaces/IAutIDAddress.sol";
import "../../daoUtils/interfaces/IDAOInteractions.sol";
import "../../daoUtils/interfaces/IDAOCommitment.sol";

import "./IDAOExpanderMembership.sol";
import "./IDAOExpanderData.sol";

/// @title IDAOExpander
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOExpander is IDAOAdmin, IDAOExpanderData, IDAOInteractions, IDAOExpanderMembership, IDAOURL, IDAOCommitment, IAutIDAddress { }