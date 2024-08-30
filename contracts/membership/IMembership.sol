//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IMembership {
    error SenderNotHub();

    event Join(address who, uint256 role, uint8 commitment);

    function join(address who, uint256 role, uint8 commitment) external;
    function members() external view returns (address[] memory);
    function isMember(address who) external view returns (bool);
    function currentRole(address who) external view returns (uint256 role);
    function membersCount() external view returns (uint256);
    function getPeriodIdJoined(address who) external view returns (uint32 periodId);
    function getPeriodIdsJoined(address[] calldata whos) external view returns (uint32[] memory);
    function getCommitment(address who, uint32 periodId) external view returns (uint8 commitment);
    function getCommitments(
        address[] calldata whos,
        uint32[] calldata periodIds
    ) external view returns (uint8[] memory);
    function commitmentSums(uint32 periodId) external view returns (uint128 commitmentSum);
    function getCommitmentSums(uint32[] calldata periodIds) external view returns (uint128[] memory);
}
