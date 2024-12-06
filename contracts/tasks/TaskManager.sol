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

    uint128 public sumPointsActive;
    uint128 public sumPointsGiven;
    uint128 public sumPointsRemoved;

    mapping(bytes32 => ContributionStatus) public contributionStatuses;
    mapping(uint32 period => PointSummary) public pointSummaries;
    mapping(address member => mapping(uint32 period => MemberActivity)) public memberActivities;
    mapping(address member => EnumerableSet.Bytes32Set) private memberContributionsGiven;
    mapping(address member => EnumerableSet.Bytes32Set) private memberContributionsCommitted;
    mapping(uint32 period => bytes32[] contributionIds) public contributionsGivenInPeriod;

    EnumerableSet.AddressSet private _contributionManagers;

    function version() external pure returns (uint256 major, uint256 minor, uint256 patch) {
        return (0, 1, 0);
    }

    constructor() {
        _disableInitializers();
    }

    function initialize(address _hub) external initializer {
        _init_AccessUtils({_hub: _hub, _autId: address(0)});
        _init_PeriodUtils();
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
        sumPointsActive += contribution.points * contribution.quantity;

        emit AddContribution({
            contributionId: contributionId,
            sender: msg.sender,
            hub: hub(),
            status: Status.Open,
            points: contribution.points,
            quantityRemaining: contribution.quantity
        });
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
        uint128 pointsRemoved = contributionStatus.points * contributionStatus.quantityRemaining;

        sumPointsActive -= pointsRemoved;
        sumPointsRemoved += pointsRemoved;
        contributionStatus.status = Status.Inactive;

        emit RemoveContribution({
            contributionId: contributionId,
            sender: msg.sender,
            hub: hub(),
            status: Status.Inactive,
            points: contributionStatus.points,
            quantityRemaining: contributionStatus.quantityRemaining
        });
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

        // revert if the contribution is not in open status (NOTE: does not require commitmentLevel to be before Contribution.endDate)
        ContributionStatus storage contributionStatus = contributionStatuses[contributionId];
        if (uint8(contributionStatus.status) != uint8(Status.Open)) revert ContributionNotOpen();

        // revert if contribution was already given to member
        if (memberContributionsGiven[who].contains(contributionId)) revert ContributionAlreadyGiven();

        // Add the commitmentLevel, revert if already committed
        if (!memberContributionsCommitted[who].add(contributionId)) revert ContributionAlreadyCommitted();

        emit CommitContribution({contributionId: contributionId, sender: msg.sender, hub: hub(), who: who, data: data});
    }

    /// @inheritdoc ITaskManager
    function revokeContributions(
        bytes32[] calldata contributionIds,
        address[] calldata whos,
        bytes[] calldata datas
    ) external {
        uint256 length = contributionIds.length;
        if (length != whos.length || length != datas.length) revert UnequalLengths();
        for (uint256 i = 0; i < length; i++) {
            _revokeContribution(contributionIds[i], whos[i], datas[i]);
        }
    }

    /// @inheritdoc ITaskManager
    function revokeContribution(bytes32 contributionId, address who, bytes calldata data) external {
        _revokeContribution(contributionId, who, data);
    }

    function _revokeContribution(bytes32 contributionId, address who, bytes memory data) internal {
        if (msg.sender != who && !isContributionManager(msg.sender) && !_isAdmin(msg.sender))
            revert UnauthorizedContributionManager();
        _revertIfNotMember(who);

        // Remove the commitmentLevel, revert if not committed
        if (!memberContributionsCommitted[who].remove(contributionId)) revert ContributionNotCommitted();

        emit RevokeContribution({contributionId: contributionId, sender: msg.sender, hub: hub(), who: who, data: data});
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

        if (!memberContributionsGiven[who].add(contributionId)) revert ContributionAlreadyGiven();
        if (!memberContributionsCommitted[who].remove(contributionId)) revert ContributionNotCommitted();

        uint32 points = contributionStatus.points;
        uint32 currentPeriod = currentPeriodId();

        // update member activity
        MemberActivity storage memberActivity = memberActivities[who][currentPeriod];
        memberActivity.pointsGiven += points;
        memberActivity.contributionIds.push(contributionId);

        // update "hot" point summary
        sumPointsActive -= points;
        sumPointsGiven += points;

        // update total contributions given in the period
        contributionsGivenInPeriod[currentPeriod].push(contributionId);

        // Finally, update contribution status and mark as complete if needed
        contributionStatus.quantityRemaining -= 1;
        if (contributionStatus.quantityRemaining == 0) {
            contributionStatus.status = Status.Complete;
        }
        emit GiveContribution({
            contributionId: contributionId,
            sender: msg.sender,
            hub: hub(),
            period: currentPeriod,
            who: who,
            status: contributionStatus.status,
            points: contributionStatus.points,
            quantityRemaining: contributionStatus.quantityRemaining
        });
    }

    /// @inheritdoc ITaskManager
    function writePointSummary() public {
        _writePointSummary(currentPeriodId());
    }

    function _writePointSummary(uint32 _currentPeriod) internal {
        uint32 lastPeriod = _currentPeriod - 1;

        // What happens if a period passes which doesn't write to storage?
        // It means in period n there was activity, period n + 1 => current period there is no activity
        uint32 i;
        bool writeToHistory;
        for (i = lastPeriod; i > 0; i--) {
            if (!pointSummaries[i].isSealed) {
                writeToHistory = true;
            } else {
                // historical commitmentLevel levels are up to date- do nothing
                break;
            }
        }

        if (writeToHistory) {
            // Write data to oldest possible period summary with no data
            pointSummaries[i] = PointSummary({
                isSealed: true,
                sumPointsActive: sumPointsActive,
                sumPointsGiven: sumPointsGiven,
                sumPointsRemoved: sumPointsRemoved
            });

            // if there's a gap in data- we have inactive periods.
            // How do we know a gap means inactive periods?
            //      Because each interaction with the members write to the point summary, keeping it synced
            if (i < lastPeriod) {
                for (uint32 j = i + 1; j < _currentPeriod; j++) {
                    pointSummaries[j] = PointSummary({
                        isSealed: true,
                        sumPointsActive: sumPointsActive,
                        sumPointsGiven: 0,
                        sumPointsRemoved: 0
                    });
                }
            }

            // Still in writeToHistory conditional...
            // Clear out the storage only relevant to the period
            delete sumPointsGiven;
            delete sumPointsRemoved;
        }
    }

    /// @inheritdoc ITaskManager
    function getContributionStatus(bytes32 contributionId) external view returns (ContributionStatus memory) {
        return contributionStatuses[contributionId];
    }

    /// @inheritdoc ITaskManager
    function getMemberActivity(address who, uint32 period) external view returns (MemberActivity memory) {
        return memberActivities[who][period];
    }

    /// @inheritdoc ITaskManager
    function getContributionPoints(bytes32 contributionId) external view returns (uint128) {
        return contributionStatuses[contributionId].points;
    }

    /// @inheritdoc ITaskManager
    function getMemberPointsGiven(address who, uint32 period) external view returns (uint128) {
        return memberActivities[who][period].pointsGiven;
    }

    /// @inheritdoc ITaskManager
    function isMemberGivenContributionId(address who, bytes32 contributionId) external view returns (bool) {
        return memberContributionsGiven[who].contains(contributionId);
    }

    /// @inheritdoc ITaskManager
    function getMemberContributionIds(address who) external view returns (bytes32[] memory) {
        return memberContributionsGiven[who].values();
    }

    /// @inheritdoc ITaskManager
    function getMemberContributionIds(address who, uint32 period) external view returns (bytes32[] memory) {
        return memberActivities[who][period].contributionIds;
    }

    /// @inheritdoc ITaskManager
    function getSumPointsActive(uint32 period) external view returns (uint128) {
        return pointSummaries[period].sumPointsActive;
    }

    /// @inheritdoc ITaskManager
    function getSumPointsGiven(uint32 period) external view returns (uint128) {
        return pointSummaries[period].sumPointsGiven;
    }

    /// @inheritdoc ITaskManager
    function getGivenContributions(uint32 period) external view returns (bytes32[] memory) {
        return contributionsGivenInPeriod[period];
    }
}
