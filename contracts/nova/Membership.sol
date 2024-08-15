// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract Membership {
    using EnumerableSet for EnumerableSet.AddressSet;

    address public hub;
    address public autID;
    address public taskManager;

    mapping(address => uint32) public joinedAt;
    mapping(address => uint32) public withdrawn;
    EnumerableSet.AddressSet[] private _members;

    struct Participation {
        uint256 role;
        uint32 commitmentLevel;
        uint128 givenContributionPoints;
        uint96 score;
        uint128 performance;
        // TODO: array of completed tasks
    }
    mapping(address who => mapping(uint32 periodId => Participation participation)) public participations;

    struct PeriodSummary {
        bool inactive;
        bool isSealed;
        uint128 sumCommitmentLevel;
    }
    mapping(uint32 periodId => PeriodSummary periodSummary) public periodSummaries;

    constructor() {}

    function _init_Membership(
        address _hub,
        address _autID,
        address _taskManager
    ) public {
        hub = _hub;
        autID = _autID;
        taskManager = _taskManager;
    }

    function members() external view returns (address[] memory) {
        return _members.values();
    }

    function isMember(address who) public view returns (bool) {
        return _members.contains(who);
    }

    function membersCount() external view returns (uint256) {
        return _members.length();
    }

    /// @notice return the period id the member joined the hub
    function getPeriodIdJoined(address who) public view returns (uint32) {
        uint32 periodIdJoined = TimeLibrary.periodId({period0Start: period0Start, timestamp: joinedAt[who]});
        if (periodIdJoined == 0) revert MemberDoesNotExist();
        return periodIdJoined;
    }


    /// @notice get the commitment level of a member at a particular period id
    function getCommitmentLevel(address who, uint32 periodId) public view returns (uint32) {
        if (periodId < getPeriodIdJoined(who)) revert MemberHasNotYetCommited();

        Participation memory participation = participations[who][periodId];
        if (participation.commitmentLevel != 0) {
            // user has changed their commitmentLevel in a period following `periodId`.  We know this becuase
            // participation.commitmentLevel state is non-zero as it is written following a commitmentLevel change.
            return participation.commitmentLevel;
        } else {
            // User has *not* changed their commitment level: meaning their commitLevel is sync to current
            return currentCommitmentLevels[who];
        }
    }

    function changeCommitmentLevel(uint8 newCommitmentLevel) external {
        uint8 oldCommitmentLevel = currentCommitmentLevels[msg.sender];
        if (newCommitmentLevel == oldCommitmentLevel) revert SameCommitmentLevel();

        // TODO: globalParam
        if (newCommitmentLevel == 0 || newCommitmentLevel > 10) revert InvalidCommitmentLevel();

        uint32 periodIdJoined = getPeriodIdJoined(msg.sender);
        uint32 currentPeriodId = TimeLibrary.periodId({period0Start: period0Start, timestamp: uint32(block.timestamp)});

        // write to storage for all 0 values- as the currentCommitmentLevels is now different
        for (uint32 i = currentPeriodId; i > periodIdJoined - 1; i--) {
            Participation storage participation = participations[msg.sender][i];
            if (participation.commitmentLevel == 0) {
                participation.commitmentLevel = oldCommitmentLevel;
            } else {
                // we have reached the end of zero values
                break;
            }
        }

        currentCommitmentLevels[msg.sender] = newCommitmentLevel;

        _writePeriodSummary(currentPeriodId);
        currentSumCommitmentLevel = currentSumCommitmentLevel - oldCommitmentLevel + newCommitmentLevel;

        emit ChangeCommitmentLevel({
            who: msg.sender,
            oldCommitmentLevel: oldCommitmentLevel,
            newCommitmentLevel: newCommitmentLevel
        });
    }

    function writeParticipations(address[] calldata whos) external {
        // update historical periods if necessary
        uint32 currentPeriodId = TimeLibrary.periodId({period0Start: period0Start, timestamp: uint32(block.timestamp)});
        _writePeriodSummary(currentPeriodId);

        for (uint256 i = 0; i < whos.length; i++) {
            _writeParticipation(whos[i], currentPeriodId);
        }
    }

    function writeParticipation(address who) external {
        // update historical periods if necessary
        uint32 currentPeriodId = TimeLibrary.periodId({period0Start: period0Start, timestamp: uint32(block.timestamp)});
        _writePeriodSummary(currentPeriodId);

        _writeParticipation(who, currentPeriodId);
    }

    // TODO: visibility?
    function _writeParticipation(address who, uint32 currentPeriodId) public {
        // TODO: algorithm
        // NOTE: in periodIdJoined, participation score is default 100.  Only write to following periods
        uint32 periodIdJoined = getPeriodIdJoined(who);

        // We are only writing to the last period which has ended: ie, currentPeriodId - 1
        uint32 periodToStartWrite;
        for (uint32 i = currentPeriodId - 1; i > periodIdJoined; i--) {
            // loop through passed periods and find the oldest period where participation has not yet been written
            if (participations[who][i].score == 0) {
                periodToStartWrite = i;
            } else {
                // we have reached the end of 0 values
                break;
            }
        }

        // return if there is nothing to write
        if (periodToStartWrite == 0) return;

        // Get previous period participation score to use as a starting weight
        uint96 previousScore = participations[who][periodToStartWrite - 1].score;

        // Start at the first empty period and write the participation score given the previous score and c
        // TODO: c from globalParameters
        uint96 constraintFactor = 4e17; // 40%
        uint96 penaltyFactor = 4e17; // 40%
        for (uint32 i = periodToStartWrite; i < currentPeriodId; i++) {
            Participation storage participation = participations[who][i];
            uint128 performance = _calcPerformanceInPeriod({
                commitmentLevel: getCommitmentLevel({who: who, periodId: i}),
                givenContributionPoints: participation.givenContributionPoints,
                periodId: i
            });

            uint96 delta;
            uint96 score;
            // TODO: precision
            if (performance > 1e18) {
                // exceeded expectations: raise participation score
                delta = uint96(performance) - 1e18;
                if (delta > constraintFactor) delta = constraintFactor;
                score = (previousScore * (1e18 + delta)) / delta;
            } else {
                // underperformed: lower participation score
                delta = 1e18 - uint96(performance);
                if (delta > penaltyFactor) delta = penaltyFactor;
                score = (previousScore * (1e18 - delta)) / delta;
            }

            // write to storage
            participation.score = score;
            participation.performance = performance;

            // overwrite previousScore to use for the next period if needed
            previousScore = score;
        }
    }

    /// @notice helper to predict performance score for any user
    function calcPerformanceInPeriod(
        uint32 commitmentLevel,
        uint128 givenContributionPoints,
        uint32 periodId
    ) public view returns (uint128) {
        uint32 currentPeriodId = TimeLibrary.periodId({period0Start: period0Start, timestamp: uint32(block.timestamp)});
        if (periodId == 0 || periodId > currentPeriodId) revert InvalidPeriodId();
        return
            _calcPerformanceInPeriod({
                commitmentLevel: commitmentLevel,
                givenContributionPoints: givenContributionPoints,
                periodId: periodId
            });
    }

    function _calcPerformanceInPeriod(
        uint32 commitmentLevel,
        uint128 givenContributionPoints,
        uint32 periodId
    ) internal view returns (uint128) {
        uint128 expectedContributionPoints = _calcExpectedContributionPoints({
            commitmentLevel: commitmentLevel,
            periodId: periodId
        });
        uint128 performance = (1e18 * givenContributionPoints) / expectedContributionPoints;
        return performance;
    }

    /// @dev returned with 1e18 precision
    function calcPerformanceInPeriod(address who, uint32 periodId) public view returns (uint128) {
        _revertForNotMember(who);
        uint32 currentPeriodId = TimeLibrary.periodId({period0Start: period0Start, timestamp: uint32(block.timestamp)});
        if (periodId == 0 || periodId > currentPeriodId) revert InvalidPeriodId();
        return _calcPerformanceInPeriod(who, periodId);
    }

    function _calcPerformanceInPeriod(address who, uint32 periodId) internal view returns (uint128) {
        return
            _calcPerformanceInPeriod({
                commitmentLevel: getCommitmentLevel(who, periodId),
                givenContributionPoints: participations[who][periodId].givenContributionPoints,
                periodId: periodId
            });
    }

    // fiCL * TCP
    function calcExpectedContributionPoints(uint32 commitmentLevel, uint32 periodId) public view returns (uint128) {
        if (commitmentLevel < 1 || commitmentLevel > 10) revert InvalidCommitmentLevel();
        uint32 currentPeriodId = TimeLibrary.periodId({period0Start: period0Start, timestamp: uint32(block.timestamp)});
        if (periodId == 0 || periodId > currentPeriodId) revert InvalidPeriodId();
        return _calcExpectedContributionPoints(commitmentLevel, periodId);
    }

    function _calcExpectedContributionPoints(uint32 commitmentLevel, uint32 periodId) internal view returns (uint128) {
        PeriodSummary memory periodSummary = periodSummaries[periodId];
        uint256 numScaled = 1e18 * uint256(commitmentLevel) * periodSummary.sumActiveContributionPoints;
        uint256 expectedContributionPoints = numScaled / periodSummary.sumCommitmentLevel / 1e18;
        return uint128(expectedContributionPoints);
    }

    /// @notice write sums to history when needed
    function writePeriodSummary() public {
        uint32 currentPeriodId = TimeLibrary.periodId({period0Start: period0Start, timestamp: uint32(block.timestamp)});
        _writePeriodSummary(currentPeriodId);
    }

    function _writePeriodSummary(uint32 _currentPeriodId) internal {
        uint32 initPeriodId_ = initPeriodId; // gas
        uint32 lastPeriodId = _currentPeriodId - 1;

        // What happens if a period passes which doesn't write to storage?
        // It means in period n there was activity, period n + 1 => current period there is no activity
        uint32 i;
        bool writeToHistory;
        for (i = lastPeriodId; i > initPeriodId_ - 1; i--) {
            PeriodSummary storage periodSummary = periodSummaries[i];
            if (periodSummary.sumCommitmentLevel == 0) {
                writeToHistory = true;
            } else {
                // historical commitment levels are up to date- do nothing
                break;
            }
        }

        if (writeToHistory) {
            // Write data to oldest possible period summary with no data
            periodSummaries[i] = PeriodSummary({
                inactive: false,
                isSealed: false,
                sumCommitmentLevel: currentSumCommitmentLevel,
                sumActiveContributionPoints: currentSumActiveContributionPoints,
                sumCreatedContributionPoints: currentSumCreatedContributionPoints,
                sumGivenContributionPoints: currentSumGivenContributionPoints,
                sumRemovedContributionPoints: currentSumRemovedContributionPoints
            });

            // if there's a gap in data- we have inactive periods. Fill up with inactive flag and empty values where possible
            if (i < lastPeriodId) {
                for (uint32 j = i + 1; j < _currentPeriodId; j++) {
                    periodSummaries[j] = PeriodSummary({
                        inactive: true,
                        isSealed: true,
                        sumCommitmentLevel: currentSumCommitmentLevel,
                        sumCreatedContributionPoints: 0,
                        sumActiveContributionPoints: currentSumActiveContributionPoints,
                        sumGivenContributionPoints: 0,
                        sumRemovedContributionPoints: 0
                    });
                }
            }

            // Still in writeToHistory conditional: clear out storage where applicable
            delete currentSumCreatedContributionPoints;
            delete currentSumGivenContributionPoints;
            delete currentSumRemovedContributionPoints;
        }
    }

    function canSeal(uint32 periodId) external view returns (bool) {
        PeriodSummary memory periodSummary = periodSummaries[periodId];
        if (periodSummary.isSealed) return false;
        uint256 length = members.length;
        for (uint256 i = 0; i < length; i++) {
            if (participations[members[i]][periodId].score == 0) {
                return false;
            }
        }
        return true;
    }

    function getMembersToWriteParticipation(uint32 periodId) external view returns (address[] memory) {
        uint256 numMembersToWrite = 0;
        uint256 length = members.length;
        address[] memory membersCopy = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            address member = members[i];
            if (participations[member][periodId].score == 0) {
                membersCopy[numMembersToWrite++] = member;
            }
        }

        address[] memory arrMembersToWrite = new address[](numMembersToWrite);
        for (uint256 i = 0; i < numMembersToWrite; i++) {
            arrMembersToWrite[i] = membersCopy[i];
        }
        return arrMembersToWrite;
    }

    // TODO: role other than admin?
    function seal(uint32 periodId) external {
        _revertForNotAdmin(msg.sender);
        PeriodSummary storage periodSummary = periodSummaries[periodId];
        if (periodSummary.isSealed) revert PeriodAlreadySealed();
        periodSummary.isSealed = true;
    }
}