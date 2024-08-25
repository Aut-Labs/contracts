//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IMembership {
    error SenderNotHub();

    event Join(address who, uint256 role, uint8 commitment);

    function initialize(
        address _taskManager,
        address _hub,
        address _autId,
        uint32 _period0Start,
        uint32 _initPeriodId
    ) external;

    function join(address who, uint256 role, uint8 commitment) external;
    function members() external view returns (address[] memory);
    function isMember(address who) external view returns (bool);
    function currentRole(address who) external view returns (uint256 role);
    function membersCount() external view returns (uint256);
    function getPeriodIdJoined(address who) external view returns (uint32 periodId);
    function getCommitment(address who, uint32 periodId) external view returns (uint8 commitment);
    function commitmentSums(uint32 periodId) external view returns (uint128 commitmentSum);
}
