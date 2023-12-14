// //SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// import "./AutIDAddress.sol";
// import "../interfaces/get/INovaAdmin.sol";
// import "../interfaces/get/INovaMembership.sol";
// import "../interfaces/get/INovaModules.sol";
// import "../../plugins/registry/IPluginRegistry.sol";
// import "../interfaces/set/INovaMembershipSet.sol";
// import "../interfaces/set/INovaAdminSet.sol";

// /// @title Nova
// /// @notice The extension of each Nova that integrates Aut
// /// @dev The extension of each Nova that integrates Aut
// abstract contract NovaMembers is INovaAdmin, INovaMembership, INovaMembershipSet, INovaAdminSet, AutIDAddress {
//     address[] public members;

//     mapping(address => bool) public override isMember;

//     /// @notice all the admin members
//     address[] public admins;
//     /// @notice mapping with the admin members
//     mapping(address => bool) public override isAdmin;

//     /// @dev Modifier for check of access of the admin member functions
//     modifier onlyAdmin() {
//         require(isAdmin[msg.sender], "Not an admin!");
//         _;
//     }

//     /// @dev role not used
//     function join(address newMember, uint256 role) public virtual override onlyAutID {
//         require(!isMember[newMember], "Already a member");
//         isMember[newMember] = true;
//         members.push(newMember);
//         emit MemberAdded();
//     }

//     /// @notice Checks if the passed member is a part of the original Nova contract depending on it's implementation of membership
//     /// @dev checks if the member is a part of a Nova
//     /// @return true if they're a member, false otherwise
//     function getAllMembers() public view override returns (address[] memory) {
//         return members;
//     }

//     /// Admins
//     /// @notice adds admins provided a member address. Plugins do not have to be members.
//     /// @param member address to add as member.
//     function addAdmin(address member) public override onlyAdmin {
//         isAdmin[member] = true;
//         admins.push(member);
//         emit AdminMemberAdded(member);
//     }

//     //// @notice adds admins provided a batch of addresses that are already members
//     //// @param adminAddr list of addresses to make admin
//     //// @dev skips if any of addresses is not already a member.
//     //// @return retruns addresses that were successfully added as admins, already admins or not members are replaced with address(0)
//     function addAdmins(address[] memory adminAddr) public override onlyAdmin returns (address[] memory) {
//         uint256 i;
//         for (i; i < adminAddr.length;) {
//             if (!isMember[adminAddr[i]]) {
//                 delete adminAddr[i];
//                 unchecked {
//                     ++i;
//                 }
//                 continue;
//             }
//             if (!isAdmin[adminAddr[i]]) {
//                 admins.push(adminAddr[i]);
//                 /// @dev
//                 isAdmin[adminAddr[i]] = true;

//                 emit AdminMemberAdded(adminAddr[i]);
//             }

//             unchecked {
//                 ++i;
//             }
//         }
//         return adminAddr;
//     }

//     function removeAdmin(address member) public override onlyAdmin {
//         for (uint256 i = 0; i < admins.length; i++) {
//             if (admins[i] == member) {
//                 admins[i] = address(0);
//             }
//         }
//         isAdmin[member] = false;
//         emit AdminMemberRemoved(member);
//     }

//     function getAdmins() public view override returns (address[] memory) {
//         return admins;
//     }

//     function memberCount() public view returns (uint256) {
//         return members.length;
//     }

//     uint256[10 - 4] private __gap;
// }
