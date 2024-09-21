// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {PeriodUtils} from "../utils/PeriodUtils.sol";
import {AccessUtils} from "../utils/AccessUtils.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Membership is Initializable, PeriodUtils, AccessUtils {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    uint128 public commitmentSum;

    mapping(address => uint32) public joinedAt;
    mapping(address => uint32) public withdrawn;
    mapping(address => uint256) public currentRole;
    mapping(address => uint8) public currentCommitment;

    EnumerableSet.AddressSet private _members;

    struct MemberDetail {
        uint256 role;
        uint8 commitment;
    }
    mapping(address who => mapping(uint32 periodId => MemberDetail)) public memberDetails;
    mapping(uint32 periodId => uint128 commitmentSum) public commitmentSums;

    error MemberDoesNotExist();
    error MemberHasNotYetCommited();
    error SenderNotHub();

    event Join(address, uint256, uint8);

    function initialize(address _hub, uint32 _period0Start, uint32 _initPeriodId) external initializer {
        _init_AccessUtils({_hub: _hub, _autId: address(0)});
        _init_PeriodUtils({_period0Start: _period0Start, _initPeriodId: _initPeriodId});
    }

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
        uint32 periodIdJoined = getPeriodId(joinedAt[who]);
        if (periodIdJoined == 0) revert MemberDoesNotExist();
        return periodIdJoined;
    }

    function getPeriodIdsJoined(address[] calldata whos) external view returns (uint32[] memory) {
        uint256 length = whos.length;
        uint32[] memory pis = new uint32[](length);
        for (uint256 i = 0; i < length; i++) {
            pis[i] = getPeriodIdJoined({who: whos[i]});
        }
        return pis;
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

    function getCommitments(
        address[] calldata whos,
        uint32[] calldata periodIds
    ) external view returns (uint8[] memory) {
        uint256 length = whos.length;
        require(length == periodIds.length);
        uint8[] memory commitments = new uint8[](length);
        for (uint256 i = 0; i < length; i++) {
            commitments[i] = getCommitment({who: whos[i], periodId: periodIds[i]});
        }
        return commitments;
    }

    function getCommitmentSum(uint32 periodId) public view returns (uint128) {
        uint32 currentPeriodId_ = currentPeriodId();
        if (periodId < initPeriodId() || periodId > currentPeriodId_) revert InvalidPeriodId();
        if (periodId == currentPeriodId_) {
            return commitmentSum;
        } else {
            return commitmentSums[periodId];
        }
    }

    function getCommitmentSums(uint32[] calldata periodIds) external view returns (uint128[] memory) {
        uint256 length = periodIds.length;
        uint128[] memory sums = new uint128[](length);
        for (uint256 i = 0; i < length; i++) {
            sums[i] = getCommitmentSum({periodId: periodIds[i]});
        }
        return sums;
    }

    // -----------------------------------------------------------
    //                          MUTATIVE
    // -----------------------------------------------------------

    function join(address who, uint256 role, uint8 commitment) public virtual {
        _revertIfNotHub();

        currentRole[who] = role;
        currentCommitment[who] = commitment;
        joinedAt[who] = uint32(block.timestamp);

        _members.add(who);

        commitmentSum += commitment;

        memberDetails[who][currentPeriodId()] = MemberDetail({role: role, commitment: commitment});

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
