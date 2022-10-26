//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../daoUtils/interfaces/get/IDAOMembership.sol";

/// @title IDAOExpander
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOExpanderMembership is IDAOMembership {

    /// @notice Checks if the passed member is a part of the original DAO contract depending on it's implementation of membership
    /// @dev checks if the member is a part of a DAO
    /// @param member the address of the member that's checked
    /// @return true if they're a member, false otherwise
    function isMemberOfOriginalDAO(address member) external view returns (bool);

}
