//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../../daoUtils/interfaces/get/IDAOAdmin.sol";
import "../../daoUtils/interfaces/get/IDAOURL.sol";
import "../../daoUtils/interfaces/get/IAutIDAddress.sol";
import "../../daoUtils/interfaces/get/IDAOInteractions.sol";
import "../../daoUtils/interfaces/get/IDAOCommitment.sol";

import "../../daoUtils/interfaces/set/IDAOAdminSet.sol";
import "../../daoUtils/interfaces/set/IDAOURLSet.sol";
import "../../daoUtils/interfaces/set/IAutIDAddressSet.sol";
import "../../daoUtils/interfaces/set/IDAOCommitmentSet.sol";
import "../../daoUtils/interfaces/set/IDAOMetadataSet.sol";

import "./IDAOExpanderMembership.sol";
import "./IDAOExpanderData.sol";

/// @title IDAOExpander
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOExpander is
    IDAOURLSet,
    IDAOCommitmentSet,
    IDAOMetadataSet,
    IDAOAdmin,
    IDAOExpanderData,
    IDAOInteractions,
    IDAOExpanderMembership,
    IDAOURL,
    IDAOCommitment,
    IAutIDAddress
{}
