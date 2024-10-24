// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {PeriodUtils} from "../utils/PeriodUtils.sol";
import {AccessUtils} from "../utils/AccessUtils.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IMembership, MemberDetail} from "./IMembership.sol";
import {IHub} from "../hub/interfaces/IHub.sol";
import {TimeLibrary} from "../libraries/TimeLibrary.sol";

contract Membership is IMembership, Initializable, PeriodUtils, AccessUtils {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    struct MembershipStorage {
        uint128 commitmentSum;
        mapping(address => uint32) joinedAt;
        mapping(address => uint32) withdrawn; // TODO
        mapping(address => uint256) currentRole;
        mapping(address => uint8) currentCommitment;
        mapping(uint32 periodId => uint128 commitmentSum) commitmentSums;
        EnumerableSet.AddressSet members;
        mapping(address who => mapping(uint32 periodId => MemberDetail)) memberDetails;
    }

    // keccak256(abi.encode(uint256(keccak256("aut.storage.Membership")) - 1))
    bytes32 private constant MembershipStorageLocation =
        0x1440776fee7f7bfe4e1069c089a4b0daf93073af4de770e17b01970530d4098c;

    function _getMembershipStorage() private pure returns (MembershipStorage storage $) {
        assembly {
            $.slot := MembershipStorageLocation
        }
    }

    constructor() {
        _disableInitializers();
    }

    function initialize(address _hub, uint32 _period0Start, uint32 _initPeriodId) external initializer {
        _init_AccessUtils({_hub: _hub, _autId: address(0)});
        _init_PeriodUtils({_period0Start: _period0Start, _initPeriodId: _initPeriodId});
    }

    // -----------------------------------------------------------
    //                          VIEWS
    // -----------------------------------------------------------

    function commitmentSum() public view returns (uint128) {
        MembershipStorage storage $ = _getMembershipStorage();
        return $.commitmentSum;
    }

    function joinedAt(address who) public view returns (uint32) {
        MembershipStorage storage $ = _getMembershipStorage();
        return $.joinedAt[who];
    }

    function withdrawn(address who) public view returns (uint32) {
        MembershipStorage storage $ = _getMembershipStorage();
        return $.withdrawn[who];
    }

    function currentRole(address who) public view returns (uint256) {
        MembershipStorage storage $ = _getMembershipStorage();
        return $.currentRole[who];
    }

    function currentCommitment(address who) public view returns (uint8) {
        MembershipStorage storage $ = _getMembershipStorage();
        return $.currentCommitment[who];
    }

    function commitmentSums(uint32 periodId) public view returns (uint128) {
        MembershipStorage storage $ = _getMembershipStorage();
        return $.commitmentSums[periodId];
    }

    /// @inheritdoc IMembership
    function members() external view returns (address[] memory) {
        MembershipStorage storage $ = _getMembershipStorage();
        return $.members.values();
    }

    /// @inheritdoc IMembership
    function isMember(address who) public view returns (bool) {
        MembershipStorage storage $ = _getMembershipStorage();
        return $.members.contains(who);
    }

    /// @inheritdoc IMembership
    function membersCount() external view returns (uint256) {
        MembershipStorage storage $ = _getMembershipStorage();
        return $.members.length();
    }

    function memberDetails(address who, uint32 periodId) external view returns (MemberDetail memory) {
        MembershipStorage storage $ = _getMembershipStorage();
        return $.memberDetails[who][periodId];
    }

    /// @inheritdoc IMembership
    function getPeriodIdJoined(address who) public view returns (uint32) {
        uint32 periodIdJoined = getPeriodId(joinedAt(who));
        if (periodIdJoined == 0) revert MemberDoesNotExist();
        return periodIdJoined;
    }

    /// @inheritdoc IMembership
    function getPeriodIdsJoined(address[] calldata whos) external view returns (uint32[] memory) {
        uint256 length = whos.length;
        uint32[] memory pis = new uint32[](length);
        for (uint256 i = 0; i < length; i++) {
            pis[i] = getPeriodIdJoined({who: whos[i]});
        }
        return pis;
    }

    /// @inheritdoc IMembership
    function getCommitment(address who, uint32 periodId) public view returns (uint8) {
        if (periodId < getPeriodIdJoined(who)) revert MemberHasNotYetCommited();

        MembershipStorage storage $ = _getMembershipStorage();
        MemberDetail memory memberDetail = $.memberDetails[who][periodId];
        if (memberDetail.commitment != 0) {
            // user has changed their commitment in a period following `periodId`.  We know this becuase
            // memberDetail.commitment state is non-zero as it is written following a commitment change.
            return memberDetail.commitment;
        } else {
            // User has *not* changed their commitment level: meaning their commitLevel is sync to current
            return $.currentCommitment[who];
        }
    }

    /// @inheritdoc IMembership
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

    /// @inheritdoc IMembership
    function getCommitmentSum(uint32 periodId) public view returns (uint128) {
        uint32 currentPeriodId_ = currentPeriodId();
        if (periodId < initPeriodId() || periodId > currentPeriodId_) revert InvalidPeriodId();
        if (periodId == currentPeriodId_) {
            return commitmentSum();
        } else {
            return commitmentSums(periodId);
        }
    }

    /// @inheritdoc IMembership
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

    /// @inheritdoc IMembership
    function join(address who, uint256 role, uint8 commitment) public virtual {
        _revertIfNotHub();

        MembershipStorage storage $ = _getMembershipStorage();

        $.currentRole[who] = role;
        $.currentCommitment[who] = commitment;
        $.joinedAt[who] = uint32(block.timestamp);

        $.members.add(who);

        $.commitmentSum += commitment;

        $.memberDetails[who][currentPeriodId()] = MemberDetail({role: role, commitment: commitment});

        emit Join(who, role, commitment);
    }

    /// @inheritdoc IMembership
    function changeCommitment(uint8 newCommitment) external {
        MembershipStorage storage $ = _getMembershipStorage();

        uint8 oldCommitment = $.currentCommitment[msg.sender];
        if (newCommitment == oldCommitment) revert SameCommitment();

        // require commitment to at least equal the hub required commitment level
        if (newCommitment > 10 || newCommitment < IHub(hub()).commitment()) revert InvalidCommitment();

        // only allow commitments for the first week
        if (block.timestamp > TimeLibrary.periodStart(uint32(block.timestamp)) + TimeLibrary.WEEK)
            revert TooLateCommitmentChange();

        uint32 periodIdJoined = getPeriodIdJoined(msg.sender);
        uint32 currentPeriodId = TimeLibrary.periodId({
            period0Start: period0Start(),
            timestamp: uint32(block.timestamp)
        });

        // write to storage for all 0 values- as the $.currentCommitment is now different
        for (uint32 i = currentPeriodId; i > periodIdJoined - 1; i--) {
            MemberDetail storage memberDetail = $.memberDetails[msg.sender][i];
            if (memberDetail.commitment == 0) {
                memberDetail.commitment = oldCommitment;
            } else {
                // we have reached the end of zero values
                break;
            }
        }

        $.currentCommitment[msg.sender] = newCommitment;
        $.commitmentSum = $.commitmentSum - uint128(oldCommitment) + uint128(newCommitment);

        emit ChangeCommitment({who: msg.sender, oldCommitment: oldCommitment, newCommitment: newCommitment});
    }

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
