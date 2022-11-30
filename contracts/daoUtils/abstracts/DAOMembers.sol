//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AutIDAddress.sol";
import "../interfaces/get/IDAOAdmin.sol";
import "../interfaces/get/IDAOMembership.sol";
import "../interfaces/set/IDAOMembershipSet.sol";
import "../interfaces/set/IDAOAdminSet.sol";

/// @title DAOExpander
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
abstract contract DAOMembers is IDAOAdmin, IDAOMembership, IDAOMembershipSet, IDAOAdminSet, AutIDAddress {

    address[] public members;

    mapping(address => bool) public override isMember;

    /// @notice all the admin members
    address[] public admins;
    /// @notice mapping with the admin members
    mapping(address => bool) public override isAdmin;

    /// @dev Modifier for check of access of the admin member functions
    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Not an admin!");
        _;
    }

    function join(address newMember) public virtual override onlyAutID {
        require(!isMember[newMember], "Already a member");
        isMember[newMember] = true;
        members.push(newMember);
        emit MemberAdded();
    }

    /// @notice Checks if the passed member is a part of the original DAO contract depending on it's implementation of membership
    /// @dev checks if the member is a part of a DAO
    /// @return true if they're a member, false otherwise
    function getAllMembers() public view override returns (address[] memory) {
        return members;
    }

    /// Admins
    function addAdmin(address member) public override onlyAdmin {
        require(isMember[member], "Not a member");
        isAdmin[member] = true;
        admins.push(member);
        emit AdminMemberAdded(member);
    }

    function removeAdmin(address member) public override onlyAdmin {
        for (uint256 i = 0; i < admins.length; i++) {
            if (admins[i] == member) {
                admins[i] = address(0);
            }
        }
        isAdmin[member] = false;
        emit AdminMemberRemoved(member);
    }

    function getAdmins() public view override returns (address[] memory) {
        return admins;
    }

    function canJoin(address member) external virtual view override returns(bool) {
        require(false, "Must be implemented");
    }
}
