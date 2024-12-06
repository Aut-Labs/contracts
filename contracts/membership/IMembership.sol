//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

struct MemberDetail {
    uint256 role;
    uint8 commitmentLevel;
}

interface IMembership {
    error MemberDoesNotExist();
    error MemberHasNotYetCommited();
    error SenderNotHub();
    error TooLateCommitmentChange();
    error SameCommitment();
    error InvalidCommitment();
    error InvalidPeriodId();

    event ChangeCommitmentLevel(address indexed who, uint8 oldCommitment, uint8 newCommitmentLevel);

    event Join(address who, uint256 role, uint8 commitmentLevel);

    /// @notice Get the current role value of a hub member
    function currentRole(address who) external view returns (uint256 role);

    /// @notice return the array of members for the hub
    function members() external view returns (address[] memory);

    /// @notice Query if an address is a member of the hub
    /// @param who Address to query
    /// @return True if address is member, else false
    function isMember(address who) external view returns (bool);

    /// @notice return the number of members for the hub
    function membersCount() external view returns (uint256);

    /// @notice Get the period ID of when the member joined the hub
    function getPeriodJoined(address who) external view returns (uint32 period);

    /// @notice Get the period ID of when an array of members joined the hub
    function getPeriodsJoined(address[] calldata whos) external view returns (uint32[] memory);

    /// @notice get the commitmentLevel level of a member at a particular period id
    function getCommitmentLevel(address who, uint32 period) external view returns (uint8 commitmentLevel);

    /// @notice get the commitmentLevel level of an array of members at a particular period id
    function getCommitmentLevels(address[] calldata whos, uint32[] calldata periods) external view returns (uint8[] memory);

    /// @notice get the cumulative commitmentLevel by members at a given period id
    function getSumCommitmentLevel(uint32 period) external view returns (uint128 sumCommitmentLevel);

    /// @notice get the cumulative commitmentLevel by members at an array of given period ids
    function getSumCommitmentLevels(uint32[] calldata periods) external view returns (uint128[] memory);

    /// @notice Join the hub
    /// @dev Is called through the hub
    function join(address who, uint256 role, uint8 commitmentLevel) external;

    /// @notice Change your commitmentLevel level
    function changeCommitmentLevel(uint8 newCommitmentLevel) external;
}
