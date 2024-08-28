//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ITaskRegistry} from "./interfaces/ITaskRegistry.sol";
import {ITaskManager} from "./interfaces/ITaskManager.sol";
import {AccessUtils} from "../utils/AccessUtils.sol";
import {PeriodUtils} from "../utils/PeriodUtils.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract TaskFactory is Initializable, PeriodUtils, AccessUtils {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    uint128 public periodPointsCreated;

    address public membership;
    address public taskRegistry;

    struct Contribution {
        bytes32 taskId;
        uint256 role;
        uint32 startDate;
        uint32 endDate;
        uint32 points;
        uint128 quantity;
        string description;
        // TODO: further identifiers
    }

    EnumerableSet.Bytes32Set private _contributionIds;
    mapping(bytes32 => Contribution) public _contributions;

    error NotContributionId();

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _hub,
        address _membership,
        address _taskRegistry,
        uint32 _period0Start,
        uint32 _initPeriodId
    ) external initializer {
        membership = _membership;
        taskRegistry = _taskRegistry;

        _init_AccessUtils({
            _hub: _hub,
            _autId: address(0)
        });
        _init_PeriodUtils({_period0Start: _period0Start, _initPeriodId: _initPeriodId});
    }


    function createContribution(Contribution calldata contribution) external {
        _revertIfNotAdmin();

        // TODO: check taskId
        bytes32 contributionId = encodeContribution(contribution);
    }



    /// @notice convert a Contribution struct into its' bytes32 identifier
    function encodeContribution(Contribution memory contribution) public pure returns (bytes32) {
        return keccak256(
            abi.encode(
                contribution.taskId,
                contribution.role,
                contribution.startDate,
                contribution.endDate,
                contribution.points,
                contribution.quantity,
                contribution.description
            )
        );
    }

    function contributions(bytes32 contributionId) external view returns (Contribution memory) {
        return _contributions[contributionId];
    }

    function contributionsAsTuple(bytes32 contributionId) external view returns (
        bytes32 taskId,
        uint256 role,
        uint32 startDate,
        uint32 endDate,
        uint32 points,
        uint128 quantity,
        string description
    ) {
        Contribution memory contribution = _contributions[contributionId];
        taskId = contribution.taskId;
        role = contribution.role;
        startDate = contribution.startDate;
        endDate = contribution.endDate;
        points = contribution.points;
        quantity = contribution.quantity;
        description = contribution.description;
    }

    function isContributionId(bytes32 contributionId) public view returns (bool) {
        return _isContributionId[contributionId];
    }
}
