//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {ITaskRegistry} from "./interfaces/ITaskRegistry.sol";
import {ITaskManager} from "./interfaces/ITaskManager.sol";
import {Contribution, ITaskFactory} from "./interfaces/ITaskFactory.sol";
import {AccessUtils} from "../utils/AccessUtils.sol";
import {PeriodUtils} from "../utils/PeriodUtils.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

// TODO: name to ContributionFactory
contract TaskFactory is ITaskFactory, Initializable, PeriodUtils, AccessUtils {
    using EnumerableSet for EnumerableSet.Bytes32Set;

    uint128 public periodPointsCreated; // TODO

    EnumerableSet.Bytes32Set private _contributionIds;
    mapping(bytes32 => Contribution) public _contributions;
    mapping(uint32 periodId => bytes32[] contributionIds) public _contributionsInPeriod;

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _hub,
        uint32 _period0Start,
        uint32 _initPeriodId
    ) external initializer {

        _init_AccessUtils({
            _hub: _hub,
            _autId: address(0)
        });
        _init_PeriodUtils({_period0Start: _period0Start, _initPeriodId: _initPeriodId});
    }

    // TODO: view of active contribtions based on expiration date

    // TODO: should access control be Hub.Admin?

    function createContributions(Contribution[] calldata contributions) external returns (bytes32[] memory) {
        uint256 length = contributions.length;
        bytes32[] memory newContributionIds = new bytes32[](length);
        for (uint256 i = 0; i < length; ) {
            newContributionIds[i] = _createContribution(contributions[i]);
            unchecked {
                ++i;
            }
        }

        return newContributionIds;
    }

    function createContribution(Contribution calldata contribution) external returns (bytes32) {
        return _createContribution(contribution);
    }

    function _createContribution(Contribution memory contribution) internal returns (bytes32) {
        if (!ITaskRegistry(taskRegistry()).isRegisteredTask(contribution.taskId)) revert TaskIdNotRegistered();
        if (contribution.quantity == 0) revert InvalidContributionQuantity(); // TODO: max quantity?
        if (contribution.points == 0 || contribution.points > 10) revert InvalidContributionPoints();

        bytes32 contributionId = encodeContribution(contribution);
        if (!_contributionIds.add(contributionId)) revert ContributionIdAlreadyExists();

        _contributions[contributionId] = contribution;
        _contributionsInPeriod[currentPeriodId()].push(contributionId);

        ITaskManager(taskManager()).addContribution(contribution, contributionId);

        // TODO: emit events

        return contributionId;
    }

    /// @notice convert a Contribution struct into its' bytes32 identifier
    function encodeContribution(Contribution memory contribution) public pure returns (bytes32) {
        return
            keccak256(
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

    function getContributionById(bytes32 contributionId) external view returns (Contribution memory) {
        return _contributions[contributionId];
    }

    function getContributionByIdAsTuple(
        bytes32 contributionId
    )
        external
        view
        returns (
            bytes32 taskId,
            uint256 role,
            uint32 startDate,
            uint32 endDate,
            uint32 points,
            uint128 quantity,
            string memory description
        )
    {
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

    function contributionsInPeriod(uint32 periodId) external view returns (bytes32[] memory) {
        return _contributionsInPeriod[periodId];
    }
}
