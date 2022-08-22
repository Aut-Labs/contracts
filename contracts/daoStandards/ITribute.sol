//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title ITribute
/// @notice The minimal interface of the TributeLabs DAORegistry contract needed for checking for a membership
interface ITribute {
    struct Member {
        // the structure to track all the members in the DAO
        uint256 flags; // flags to track the state of the member: exists, etc
    }

    function members(address member) external view returns(Member memory);
}
