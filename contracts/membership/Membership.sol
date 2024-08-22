// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { IPeriodUtils } from "../utils/interfaces/IPeriodUtils.sol";
import { IAccessUtils} from "../utils/interfaces/IAccessUtils.sol";

abstract contract Membership is IPeriodUtils, IAccessUtils {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    // globally shared
    uint32 public period0Start;
    uint32 public initPeriodId;
    address public hub;
    address public autID;
    
    uint128 public commitmentSum;

    mapping(address => uint32) public joinedAt;
    mapping(address => uint32) public withdrawn;
    mapping(address => uint256) public currentRole;
    mapping(address => uint8) public currentCommitment;
    
    EnumerableSet.AddressSet[] private _members;

    struct MemberDetail {
        uint128 role;
        uint8 commitment;
    }
    mapping(address who => mapping(uint32 periodId => MemberDetail)) public memberDetails;
    mapping(uint32 periodId => uint128 commitmentSum) public commitmentSums;

    error MemberDoesNotExist();
    error MemberHasNotYetCommited();
    error InvalidPeriodId();
    error SenderNotHub();

    event Join(address, uint256, uint8);

    // -----------------------------------------------------------
    //                          VIEWS
    // -----------------------------------------------------------

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
        uint32 periodIdJoined = this.getPeriodId(joinedAt[who]);
        if (periodIdJoined == 0) revert MemberDoesNotExist();
        return periodIdJoined;
    }


    /// @notice get the commitment level of a member at a particular period id
    function getCommitment(address who, uint32 periodId) public view returns (uint8) {
        if (periodId < getPeriodIdJoined(who)) revert MemberHasNotYetCommited();

        MemberDetail memory memberDetail = memberDetails[who][periodId];
        if (memberDetail.commitment != 0) {
            // user has changed their commitment in a period following `periodId`.  We know this becuase
            // memberDetail.commitment state is non-zero as it is written following a commitment change.
            return memberDetail.commitment;
        } else {
            // User has *not* changed their commitment level: meaning their commitLevel is sync to current
            return currentCommitment[who];
        }
    }

    function getCommitmentSum(uint32 periodId) external view returns (uint128) {
        uint32 currentPeriodId_ = this.currentPeriodId();
        if (periodId < initPeriodId || periodId > currentPeriodId_) revert InvalidPeriodId();
        if (periodId == currentPeriodId_) {
            return commitmentSum;
        } else {
            return commitmentSums[periodId];
        }
    }

    // -----------------------------------------------------------
    //                          MUTATIVE
    // -----------------------------------------------------------

    function join(address who, uint256 role, uint8 commitment) public virtual {
        if (msg.sender != hub()) revert SenderNotHub();
        
        currentRole[who] = role;
        currentCommitment[who] = commitment;
        joinedAt[who] = uint32(block.timestamp);

        _members.add(who);

        commitmentSum += commitment;

        memberDetails[who][this.currentPeriodId()] = MemberDetail({
            role: role,
            commitment: commitment
        });

        emit Join(who, role, commitment);
    }

    // function changeCommitment(uint8 newCommitment) external {
    //     uint8 oldCommitment = currentCommitments[msg.sender];
    //     if (newCommitment == oldCommitment) revert SameCommitment();

    //     // TODO: globalParam
    //     if (newCommitment == 0 || newCommitment > 10) revert InvalidCommitment();

    //     uint32 periodIdJoined = getPeriodIdJoined(msg.sender);
    //     uint32 currentPeriodId = TimeLibrary.periodId({period0Start: period0Start, timestamp: uint32(block.timestamp)});

    //     // write to storage for all 0 values- as the currentCommitments is now different
    //     for (uint32 i = currentPeriodId; i > periodIdJoined - 1; i--) {
    //         Participation storage participation = participations[msg.sender][i];
    //         if (participation.commitment == 0) {
    //             participation.commitment = oldCommitment;
    //         } else {
    //             // we have reached the end of zero values
    //             break;
    //         }
    //     }

    //     currentCommitments[msg.sender] = newCommitment;

    //     _writePeriodSummary(currentPeriodId);
    //     currentSumCommitment = currentSumCommitment - oldCommitment + newCommitment;

    //     emit ChangeCommitment({
    //         who: msg.sender,
    //         oldCommitment: oldCommitment,
    //         newCommitment: newCommitment
    //     });
    // }

    // function canSeal(uint32 periodId) external view returns (bool) {
    //     PeriodSummary memory periodSummary = periodSummaries[periodId];
    //     if (periodSummary.isSealed) return false;
    //     uint256 length = members.length;
    //     for (uint256 i = 0; i < length; i++) {
    //         if (participations[members[i]][periodId].score == 0) {
    //             return false;
    //         }
    //     }
    //     return true;
    // }

    // TODO: role other than admin?
    // function seal(uint32 periodId) external {
    //     _revertForNotAdmin(msg.sender);
    //     PeriodSummary storage periodSummary = periodSummaries[periodId];
    //     if (periodSummary.isSealed) revert PeriodAlreadySealed();
    //     periodSummary.isSealed = true;
    // }
}