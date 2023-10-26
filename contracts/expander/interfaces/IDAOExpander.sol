//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../../components/interfaces/get/INovaAdmin.sol";
import "../../components/interfaces/get/INovaUrls.sol";
import "../../components/interfaces/get/IAutIDAddress.sol";
import "../../components/interfaces/get/INovaCommitment.sol";

import "../../components/interfaces/set/INovaAdminSet.sol";
import "../../components/interfaces/set/INovaUrlsSet.sol";
import "../../components/interfaces/set/IAutIDAddressSet.sol";
import "../../components/interfaces/set/INovaCommitmentSet.sol";
import "../../components/interfaces/set/INovaMetadataSet.sol";

import "./IDAOExpanderMembership.sol";
import "./IDAOExpanderData.sol";

/// @title IDAOExpander
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOExpander is
    INovaUrlsSet,
    INovaCommitmentSet,
    INovaMetadataSet,
    INovaAdmin,
    IDAOExpanderData,
    IDAOExpanderMembership,
    INovaUrls,
    INovaCommitment,
    IAutIDAddress
{}
