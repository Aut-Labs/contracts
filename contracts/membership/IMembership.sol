//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;



interface IMembership {
    function members() external view returns (address[] memory);
    function isMember(address) external view returns (bool);
    function membersCount() external view returns (uint256);
    function getPeriodIdJoined(address) external view returns (uint32);
    function getCommitmentLevel(address, uint32) external view returns (uint8);
}