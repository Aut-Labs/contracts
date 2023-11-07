//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title INova
/// @notice The interface for the extension of each Nova that integrates AutID
interface INovaMembershipSet {
    event MemberAdded();

    function join(address newMember, uint256 role) external;
}
