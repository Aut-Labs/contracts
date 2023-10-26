//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title INova
/// @notice The interface for the extension of each DAO that integrates AutID
interface INovaMembership {
    function isMember(address member) external view returns (bool);

    function getAllMembers() external view returns (address[] memory);

    function canJoin(address member, uint256 role) external view returns (bool);
}
