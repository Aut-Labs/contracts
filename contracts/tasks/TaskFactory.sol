//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract TaskFactory is Initializable {

    uint128 public currentSumPoints;

    address public hub;
    address public membership;

    struct MetaTask {
        bytes32 taskId;
        uint256 role;
        uint32 startDate;
        uint32 endDate;
        uint32 points;
        uint128 quantity;
        string description;
        // TODO: further identifiers
    }

    mapping(bytes32 => bool) public taskId;

    function initialize(address _hub, address _membership) external initializer {
        hub = _hub;
        membership = _membership;
    }

    function createTask(MetaTask calldata task) external {
        
    }
}
