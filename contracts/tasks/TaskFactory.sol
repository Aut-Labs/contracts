//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ITaskRegistry} from "./interfaces/ITaskRegistry.sol";
import {ITaskManager} from "./interfaces/ITaskManager.sol";
import {AccessUtils} from "../utils/AccessUtils.sol";
import {PeriodUtils} from "../utils/PeriodUtils.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

// TODO: name to ContributionFactory
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
    error TaskIdNotRegistered();
    error ContributionIdAlreadyExists();
    error InvalidContributionQuantity();
    error InvalidContributionPoints();
    constructor() {
        _disableInitializers();
    }

    function initialize(
        // address _hub,
        address _membership,
        address _taskRegistry,
        // uint32 _period0Start,
        // uint32 _initPeriodId
    ) external initializer {
        membership = _membership;
        taskRegistry = _taskRegistry;

        // _init_AccessUtils({
        //     _hub: _hub,
        //     _autId: address(0)
        // });
        // _init_PeriodUtils({_period0Start: _period0Start, _initPeriodId: _initPeriodId});
    }

    // TODO: should access control be Hub.Admin?

    function createContributions(Contribution[] calldata contributions) external {

        uint256 length = contributions.length;
        for (uint256 i=0; i<length;) {
            _createContribution(contributions[i]);
            unchecked {
                ++i;
            }
        }
    }

    function createContribution(Contribution calldata contribution) external {
        _createContribution(contribution);
    }

    function _createContribution(Contribution memory contribution) internal {
        if (!ITaskRegisty(taskRegistry).isRegisteredTask(contribution.taskId)) revert TaskIdNotRegistered();
        if (contribution.quantity == 0) revert InvalidContributionQuantity(); // TODO: max quantity?
        if (contribution.points == 0 || contribution.points > 10) revert InvalidContributionPoints();
        

        bytes32 contributionId = encodeContribution(contribution);
        if (!_contributionIds.add(contributionId)) revert ContributionIdAlreadyExists();

        _contributions[contributionId] = contribution;

        uint256 pointsCreated = contribution.points * contribution.quantity;

        // TODO: write to ContributionManager
        ITaskManager(taskManager).

        // TODO: store points created in a period?

        // TODO: write contributionId to contributionsInPeriod
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
        return _contributionIds.contains(contributionId);
    }

    function contributionIds() external view returns (bytes32[] memory) {
        return _contributionIds.values();
    }
}
