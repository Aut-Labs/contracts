//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IMembership {
    error MemberDoesNotExist();
    error MemberHasNotYetCommited();
    error SenderNotHub();

    event Join(address who, uint256 role, uint8 commitment);

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
    function getPeriodIdJoined(address who) external view returns (uint32 periodId);

    /// @notice Get the period ID of when an array of members joined the hub
    function getPeriodIdsJoined(address[] calldata whos) external view returns (uint32[] memory);

    /// @notice get the commitment level of a member at a particular period id
    function getCommitment(address who, uint32 periodId) external view returns (uint8 commitment);

    /// @notice get the commitment level of an array of members at a particular period id
    function getCommitments(
        address[] calldata whos,
        uint32[] calldata periodIds
    ) external view returns (uint8[] memory);

    /// @notice get the cumulative commitment by members at a given period id
    function getCommitmentSum(uint32 periodId) external view returns (uint128 commitmentSum);

    /// @notice get the cumulative commitment by members at an array of given period ids
    function getCommitmentSums(uint32[] calldata periodIds) external view returns (uint128[] memory);

    /// @notice Join the hub
    /// @dev Is called through the hub
    function join(address who, uint256 role, uint8 commitment) external;
}
