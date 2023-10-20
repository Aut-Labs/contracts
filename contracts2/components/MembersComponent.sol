// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "../base/ComponentBase.sol";
import "../utils/Semver.sol";

contract MembersComponent is ComponentBase, Semver(0, 1, 0) {
    event Joined(address who);

    address[] public members;
    mapping(address => bool) public isMember;

    function join(address newMember) public {
        require(!isMember[newMember], "MembersComponent: already joined");
        isMember[newMember] = true;
        emit Joined(newMember);
    }

    function membersCount() external view returns(uint256) {
        return members.length;
    }

    function membersPage(uint256 from, uint256 to) external returns(address[] memory) {

    }
    
}