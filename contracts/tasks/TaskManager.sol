//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {PeriodUtils} from "../utils/PeriodUtils.sol";
import {AccessUtils} from "../utils/AccessUtils.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ContributionManager is Initializable, PeriodUtils, AccessUtils {
    uint128 public pointsActive;
    uint128 public periodPointsGiven;
    uint128 public periodPointsRemoved;

    enum Status {
        None,
        Open,
        Inactive,
        Complete
    }

    struct ContributionStatus {
        Status status;
        uint32 points;
        uint128 quantityRemaining;
    }
    mapping(bytes32 => ContributionStatus) public contributionStatuses;
    mapping(uint32 periodId => bytes32[] contributionIds) public contributionsInPeriod;

    struct PointSummary {
        bool isSealed;
        uint128 pointsActive;
        uint128 pointsGiven;
        uint128 pointsRemoved;
    }
    mapping(uint32 periodId => PointSummary) public pointSummaries;

    struct MemberActivity {
        uint128 pointsGiven;
        bytes32[] contributionIds;
    }
    mapping(address member => mapping(uint32 periodId => MemberActivity)) public memberActivities;

    error UnequalLengths();

    constructor() {
        _disableInitializers();
    }

    function initialize(address _hub, address _autId, uint32 _period0Start, uint32 _initPeriodId) external initializer {
        _init_AccessUtils({_hub: _hub, _autId: _autId});
        _init_PeriodUtils({_period0Start: _period0Start, _initPeriodId: _initPeriodId});
    }

    function currentContributionId() public view returns (uint256) {
        return tasks.length - 1;
    }

    function getContributionStatus(uint256 taskId) external view returns (ContributionStatus) {
        // TODO
    }

    function getContributionWeight(uint256 taskId) external view returns (uint128) {
        // TODO
    }

    function getActiveContributions(uint32 periodId) external view returns (Contribution[] memory) {
        // TODO
    }

    function getGivenContributionPoints(address who, uint32 periodId) external view returns (uint128) {
        // TODO
    }

    function getPointsActive(uint32 periodId) external view returns (uint128) {
        return pointSummaries[periodId].pointsActive;
    }

    function getPointsGiven(uint32 periodId) external view returns (uint128) {
        return pointSummaries[periodId].pointsGiven;
    }

    function getMemberPointsGiven(address who, uint32 periodId) external view returns (uint128) {
        return memberActivities[who][periodId].pointsGiven;
    }

    function getCompletedContributions(uint32 periodId) external view returns (Contribution[] memory) {
        // TODO: how should completed tasks be stored? is it by each time task points
        // are given or when the task is fully completed X many times?
    }

    function addContribution(Contribution calldata contribution) public {
        // _revertIfNotAdmin();
        writePointSummary();

        _addContribution(contribution);
    }

    function _addContribution(
        Contribution memory contribution,
        bytes32 contributionId
    ) internal {
        contributionStatuses[contributionId] = ContributionStatus({
            status: Status.Open,
            points: contribution.points,
            quantityRemaining: contribution.quantity
        });
        contributionsInPeriod[currentPeriodId()].push(contributionId);

        // uint128 sumContributionContributionPoints = contribution.contributionPoints * contribution.quantity;
        // currentSumActiveContributionPoints += sumContributionContributionPoints;
        // currentSumCreatedContributionPoints += sumContributionContributionPoints;
        // tasks.push(contribution);
        // TODO: events
    }

    function removeContributions(uint256[] memory contributionIds) external {
        _revertIfNotAdmin();
        writePointSummary();
        for (uint256 i = 0; i < contributionIds.length; i++) {
            _removeContribution(contributionIds[i]);
        }
    }

    function removeContribution(uint256 contributionId) external {
        _revertIfNotAdmin();
        writePointSummary();
        _removeContribution(contributionId);
    }

    function _removeContribution(uint256 contributionId) internal {
        // Contribution memory task = tasks[contributionId];
        // if (task.quantity == 0) revert ContributionNotActive();
        // // NOTE: does not subtract from created tasks
        // uint128 sumContributionContributionPoints = task.contributionPoints * task.quantity;
        // currentSumActiveContributionPoints -= sumContributionContributionPoints;
        // currentSumRemovedContributionPoints += sumContributionContributionPoints;
        // delete tasks[contributionId];
        // TODO: event
    }

    function giveContributions(uint256[] memory contributionIds, address[] memory _members) external {
        _revertIfNotAdmin();
        uint256 length = contributionIds.length;
        if (length != _members.length) revert UnequalLengths();
        for (uint256 i = 0; i < length; i++) {
            _giveContribution(contributionIds[i], _members[i]);
        }
    }

    function giveContribution(uint256 contributionId, address _member) external {
        _revertIfNotAdmin();
        _giveContribution(contributionId, _member);
    }

    function _giveContribution(uint256 contributionId, address _member) internal {
        // Contribution storage task = tasks[contributionId];
        // if (task.quantity == 0) revert ContributionNotActive();
        // if (joinedAt[_member] == 0) revert MemberDoesNotExist();
        // Participation storage participation = participations[_member][currentPeriodId()];
        // uint128 contributionPoints = task.contributionPoints;
        // participation.givenContributionPoints += contributionPoints;
        // currentSumGivenContributionPoints += contributionPoints;
        // currentSumActiveContributionPoints -= contributionPoints;
        // task.quantity--;
        // TODO: push task to user balance (as nft)
    }

    /// @notice write sums to history when needed
    function writePointSummary() public {
        _writePointSummary(currentPeriodId());
    }

    function _writePointSummary(uint32 _currentPeriodId) internal {
        uint32 initPeriodId_ = initPeriodId(); // gas
        uint32 lastPeriodId = _currentPeriodId - 1;

        // What happens if a period passes which doesn't write to storage?
        // It means in period n there was activity, period n + 1 => current period there is no activity
        uint32 i;
        bool writeToHistory;
        for (i = lastPeriodId; i > initPeriodId_ - 1; i--) {
            if (!pointSummaries[i].isSealed) {
                writeToHistory = true;
            } else {
                // historical commitment levels are up to date- do nothing
                break;
            }
        }

        if (writeToHistory) {
            // Write data to oldest possible period summary with no data
            pointSummaries[i] = PointSummary({
                isSealed: true,
                pointsActive: pointsActive,
                pointsCreated: periodPointsCreated,
                pointsGiven: periodPointsGiven,
                pointsRemoved: periodPointsRemoved
            });

            // if there's a gap in data- we have inactive periods.
            // How do we know a gap means inactive periods?
            //      Because each interaction with the members tasks write to the task summary, keeping it synced
            if (i < lastPeriodId) {
                for (uint32 j = i + 1; j < _currentPeriodId; j++) {
                    pointSummaries[j] = PointSummary({
                        isSealed: true,
                        pointsActive: pointsActive,
                        pointsCreated: 0,
                        pointsGiven: 0,
                        pointsRemoved: 0
                    });
                }
            }

            // Still in writeToHistory conditional...
            // Clear out the storage only relevant to the period
            delete periodPointsCreated;
            delete periodPointsGiven;
            delete periodPointsRemoved;
        }
    }
}
