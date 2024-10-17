//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {PeriodUtils} from "../utils/PeriodUtils.sol";
import {AccessUtils} from "../utils/AccessUtils.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {Status, ContributionStatus, PointSummary, MemberActivity, ITaskManager} from "./interfaces/ITaskManager.sol";
import {Contribution} from "./interfaces/ITaskFactory.sol";

contract TaskManager is ITaskManager, Initializable, PeriodUtils, AccessUtils {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    uint128 public pointsActive;
    uint128 public periodPointsGiven;
    uint128 public periodPointsRemoved;

    mapping(bytes32 => ContributionStatus) public contributionStatuses;
    mapping(uint32 periodId => PointSummary) public pointSummaries;
    mapping(address member => mapping(uint32 periodId => MemberActivity)) public memberActivities;
    mapping(address member => EnumerableSet.Bytes32Set) private memberContributions;
    mapping(uint32 periodId => bytes32[] contributionIds) public contributionsGivenInPeriod;

    EnumerableSet.AddressSet private _contributionManagers;

    constructor() {
        _disableInitializers();
    }

    function initialize(address _hub, uint32 _period0Start, uint32 _initPeriodId) external initializer {
        _init_AccessUtils({_hub: _hub, _autId: address(0)});
        _init_PeriodUtils({_period0Start: _period0Start, _initPeriodId: _initPeriodId});
    }

    /// @dev set the initial contribution manager from the hub registry
    function initialize2(address initialContributionManager) external reinitializer(2) {
        _addContributionManager(initialContributionManager);
    }

    // ContributionManager-management

    /// @inheritdoc ITaskManager
    function addContributionManager(address who) external {
        _revertIfNotAdmin();
        _addContributionManager(who);
    }

    function _addContributionManager(address who) internal {
        if (!_contributionManagers.add(who)) revert AlreadyContributionManager();
        emit AddContributionManager(who);
    }

    /// @inheritdoc ITaskManager
    function removeContributionManager(address who) external {
        _revertIfNotAdmin();
        if (!_contributionManagers.remove(who)) revert NotContributionManager();

        emit RemoveContributionManager(who);
    }

    /// @inheritdoc ITaskManager
    function isContributionManager(address who) public view returns (bool) {
        return _contributionManagers.contains(who);
    }

    /// @inheritdoc ITaskManager
    function contributionManagers() external view returns (address[] memory) {
        return _contributionManagers.values();
    }

    // Contribution-management

    /// @inheritdoc ITaskManager
    function addContribution(bytes32 contributionId, Contribution calldata contribution) public {
        _revertIfNotTaskFactory();
        writePointSummary();

        _addContribution(contributionId, contribution);
    }

    function _addContribution(bytes32 contributionId, Contribution memory contribution) internal {
        ContributionStatus memory contributionStatus = ContributionStatus({
            status: Status.Open,
            points: contribution.points,
            quantityRemaining: contribution.quantity
        });
        contributionStatuses[contributionId] = contributionStatus;
        pointsActive += contribution.points * contribution.quantity;

        emit AddContribution(contributionId, encodeContributionStatus(contributionStatus));
    }

    /// @inheritdoc ITaskManager
    function removeContributions(bytes32[] calldata contributionIds) external {
        _revertIfNotAdmin();
        writePointSummary();
        for (uint256 i = 0; i < contributionIds.length; i++) {
            _removeContribution(contributionIds[i]);
        }
    }

    /// @inheritdoc ITaskManager
    function removeContribution(bytes32 contributionId) external {
        _revertIfNotAdmin();
        writePointSummary();
        _removeContribution(contributionId);
    }

    function _removeContribution(bytes32 contributionId) internal {
        ContributionStatus storage contributionStatus = contributionStatuses[contributionId];
        if (uint8(contributionStatus.status) != uint8(Status.Open)) revert ContributionNotOpen();

        // NOTE: does not subtract from created contributions
        uint128 sumPointsRemoved = contributionStatus.points * contributionStatus.quantityRemaining;

        pointsActive -= sumPointsRemoved;
        periodPointsRemoved += sumPointsRemoved;
        contributionStatus.status = Status.Inactive;

        emit RemoveContribution(contributionId, encodeContributionStatus(contributionStatus));
    }

    /// @inheritdoc ITaskManager
    function commitContributions(
        bytes32[] calldata contributionIds,
        address[] calldata whos,
        bytes[] calldata datas
    ) external {
        uint256 length = contributionIds.length;
        if (length != whos.length || length != datas.length) revert UnequalLengths();
        for (uint256 i = 0; i < length; i++) {
            _commitContribution(contributionIds[i], whos[i], datas[i]);
        }
    }

    /// @inheritdoc ITaskManager
    function commitContribution(bytes32 contributionId, address who, bytes calldata data) external {
        _commitContribution(contributionId, who, data);
    }

    function _commitContribution(bytes32 contributionId, address who, bytes memory data) internal {
        if (msg.sender != who && !isContributionManager(msg.sender) && !_isAdmin(msg.sender))
            revert UnauthorizedContributionManager();
        _revertIfNotMember(who);

        ContributionStatus storage contributionStatus = contributionStatuses[contributionId];
        if (uint8(contributionStatus.status) != uint8(Status.Open)) revert ContributionNotOpen();
        emit CommitContribution(contributionId, msg.sender, who, data);
    }

    /// @inheritdoc ITaskManager
    function giveContributions(bytes32[] calldata contributionIds, address[] calldata whos) external {
        if (!isContributionManager(msg.sender) && !_isAdmin(msg.sender)) revert UnauthorizedContributionManager();
        writePointSummary();

        uint256 length = contributionIds.length;
        if (length != whos.length) revert UnequalLengths();
        for (uint256 i = 0; i < length; i++) {
            _giveContribution(contributionIds[i], whos[i]);
        }
    }

    /// @inheritdoc ITaskManager
    function giveContribution(bytes32 contributionId, address who) external {
        if (!isContributionManager(msg.sender) && !_isAdmin(msg.sender)) revert UnauthorizedContributionManager();
        writePointSummary();
        _giveContribution(contributionId, who);
    }

    function _giveContribution(bytes32 contributionId, address who) internal {
        _revertIfNotMember(who);

        ContributionStatus storage contributionStatus = contributionStatuses[contributionId];
        if (uint8(contributionStatus.status) != uint8(Status.Open)) revert ContributionNotOpen();
        uint32 points = contributionStatus.points;

        uint32 currentPeriodId_ = currentPeriodId();

        // update member activity
        MemberActivity storage memberActivity = memberActivities[who][currentPeriodId_];
        memberActivity.pointsGiven += points;
        memberActivity.contributionIds.push(contributionId);

        if (!memberContributions[who].add(contributionId)) revert MemberAlreadyContributed();

        // update "hot" point summary
        pointsActive -= points;
        periodPointsGiven += points;

        // update total contributions given in the period
        contributionsGivenInPeriod[currentPeriodId_].push(contributionId);

        // Finally, update contribution status and mark as complete if needed
        contributionStatus.quantityRemaining -= 1;
        if (contributionStatus.quantityRemaining == 0) {
            contributionStatus.status = Status.Complete;
        }

        emit GiveContribution(contributionId, who, currentPeriodId_, encodeContributionStatus(contributionStatus));
    }

    /// @inheritdoc ITaskManager
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
                pointsGiven: periodPointsGiven,
                pointsRemoved: periodPointsRemoved
            });

            // if there's a gap in data- we have inactive periods.
            // How do we know a gap means inactive periods?
            //      Because each interaction with the members write to the point summary, keeping it synced
            if (i < lastPeriodId) {
                for (uint32 j = i + 1; j < _currentPeriodId; j++) {
                    pointSummaries[j] = PointSummary({
                        isSealed: true,
                        pointsActive: pointsActive,
                        pointsGiven: 0,
                        pointsRemoved: 0
                    });
                }
            }

            // Still in writeToHistory conditional...
            // Clear out the storage only relevant to the period
            delete periodPointsGiven;
            delete periodPointsRemoved;
        }
    }

    /// @inheritdoc ITaskManager
    function getContributionStatus(bytes32 contributionId) external view returns (ContributionStatus memory) {
        return contributionStatuses[contributionId];
    }

    /// @inheritdoc ITaskManager
    function getMemberActivity(address who, uint32 periodId) external view returns (MemberActivity memory) {
        return memberActivities[who][periodId];
    }

    /// @inheritdoc ITaskManager
    function getContributionPoints(bytes32 contributionId) external view returns (uint128) {
        return contributionStatuses[contributionId].points;
    }

    /// @inheritdoc ITaskManager
    function getMemberPointsGiven(address who, uint32 periodId) external view returns (uint128) {
        return memberActivities[who][periodId].pointsGiven;
    }

    /// @inheritdoc ITaskManager
    function getMemberContributionIds(address who, uint32 periodId) external view returns (bytes32[] memory) {
        return memberActivities[who][periodId].contributionIds;
    }

    /// @inheritdoc ITaskManager
    function getPointsActive(uint32 periodId) external view returns (uint128) {
        return pointSummaries[periodId].pointsActive;
    }

    /// @inheritdoc ITaskManager
    function getPointsGiven(uint32 periodId) external view returns (uint128) {
        return pointSummaries[periodId].pointsGiven;
    }

    /// @inheritdoc ITaskManager
    function getGivenContributions(uint32 periodId) external view returns (bytes32[] memory) {
        return contributionsGivenInPeriod[periodId];
    }

    /// @inheritdoc ITaskManager
    function encodeContributionStatus(ContributionStatus memory contributionStatus) public pure returns (bytes memory) {
        return
            abi.encodePacked(
                contributionStatus.status,
                contributionStatus.points,
                contributionStatus.quantityRemaining
            );
    }
}
