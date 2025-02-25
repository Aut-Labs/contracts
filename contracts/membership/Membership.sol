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
        uint128 sumCommitmentLevel;
        mapping(address => uint32) joinedAt;
        mapping(address => uint32) withdrawn; // TODO
        mapping(address => uint256) currentRole;
        mapping(address => uint8) currentCommitmentLevel;
        mapping(uint32 period => uint128 sumCommitmentLevel) sumCommitmentLevels;
        EnumerableSet.AddressSet members;
        mapping(address who => mapping(uint32 period => MemberDetail)) memberDetails;
    }

    // keccak256(abi.encode(uint256(keccak256("aut.storage.Membership")) - 1))
    bytes32 private constant MembershipStorageLocation =
        0x1440776fee7f7bfe4e1069c089a4b0daf93073af4de770e17b01970530d4098c;

    function _getMembershipStorage() private pure returns (MembershipStorage storage $) {
        assembly {
            $.slot := MembershipStorageLocation
        }
    }

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

    // -----------------------------------------------------------
    //                          VIEWS
    // -----------------------------------------------------------

    function sumCommitmentLevel() public view returns (uint128) {
        MembershipStorage storage $ = _getMembershipStorage();
        return $.sumCommitmentLevel;
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

    function currentCommitmentLevel(address who) public view returns (uint8) {
        MembershipStorage storage $ = _getMembershipStorage();
        return $.currentCommitmentLevel[who];
    }

    function sumCommitmentLevels(uint32 period) public view returns (uint128) {
        MembershipStorage storage $ = _getMembershipStorage();
        return $.sumCommitmentLevels[period];
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

    function memberDetails(address who, uint32 period) external view returns (MemberDetail memory) {
        MembershipStorage storage $ = _getMembershipStorage();
        return $.memberDetails[who][period];
    }

    /// @inheritdoc IMembership
    function getPeriodJoined(address who) public view returns (uint32) {
        uint32 periodJoined = periodId(joinedAt(who));
        if (periodJoined == 0) revert MemberDoesNotExist();
        return periodJoined;
    }

    /// @inheritdoc IMembership
    function getPeriodsJoined(address[] calldata whos) external view returns (uint32[] memory) {
        uint256 length = whos.length;
        uint32[] memory pis = new uint32[](length);
        for (uint256 i = 0; i < length; i++) {
            pis[i] = getPeriodJoined({who: whos[i]});
        }
        return pis;
    }

    /// @inheritdoc IMembership
    function getCommitmentLevel(address who, uint32 period) public view returns (uint8) {
        if (period < getPeriodJoined(who)) revert MemberHasNotYetCommited();

        MembershipStorage storage $ = _getMembershipStorage();
        MemberDetail memory memberDetail = $.memberDetails[who][period];
        if (memberDetail.commitmentLevel != 0) {
            // user has changed their commitmentLevel in a period following `period`.  We know this becuase
            // memberDetail.commitmentLevel state is non-zero as it is written following a commitmentLevel change.
            return memberDetail.commitmentLevel;
        } else {
            // User has *not* changed their commitmentLevel level: meaning their commitLevel is sync to current
            return $.currentCommitmentLevel[who];
        }
    }

    /// @inheritdoc IMembership
    function getCommitmentLevels(
        address[] calldata whos,
        uint32[] calldata period
    ) external view returns (uint8[] memory) {
        uint256 length = whos.length;
        require(length == period.length);
        uint8[] memory commitments = new uint8[](length);
        for (uint256 i = 0; i < length; i++) {
            commitments[i] = getCommitmentLevel({who: whos[i], period: period[i]});
        }
        return commitments;
    }

    /// @inheritdoc IMembership
    function getSumCommitmentLevel(uint32 period) public view returns (uint128) {
        uint32 currentPeriod = currentPeriodId();
        if (period == 0 || period > currentPeriod) revert InvalidPeriodId();
        if (period == currentPeriod) {
            return sumCommitmentLevel();
        } else {
            return sumCommitmentLevels(period);
        }
    }

    /// @inheritdoc IMembership
    function getSumCommitmentLevels(uint32[] calldata periods) external view returns (uint128[] memory) {
        uint256 length = periods.length;
        uint128[] memory sums = new uint128[](length);
        for (uint256 i = 0; i < length; i++) {
            sums[i] = getSumCommitmentLevel({period: periods[i]});
        }
        return sums;
    }

    // -----------------------------------------------------------
    //                          MUTATIVE
    // -----------------------------------------------------------

    /// @inheritdoc IMembership
    function join(address who, uint256 role, uint8 commitmentLevel) public virtual {
        _revertIfNotHub();

        MembershipStorage storage $ = _getMembershipStorage();

        $.currentRole[who] = role;
        $.currentCommitmentLevel[who] = commitmentLevel;
        $.joinedAt[who] = uint32(block.timestamp);

        $.members.add(who);

        $.sumCommitmentLevel += commitmentLevel;

        $.memberDetails[who][currentPeriodId()] = MemberDetail({role: role, commitmentLevel: commitmentLevel});

        emit Join(who, role, commitmentLevel);
    }

    /// @inheritdoc IMembership
    function changeCommitmentLevel(uint8 newCommitmentLevel) external {
        MembershipStorage storage $ = _getMembershipStorage();

        uint8 oldCommitment = $.currentCommitmentLevel[msg.sender];
        if (newCommitmentLevel == oldCommitment) revert SameCommitment();

        // require commitmentLevel to at least equal the hub required commitmentLevel level
        if (newCommitmentLevel > 10 || newCommitmentLevel < IHub(hub()).commitmentLevel()) revert InvalidCommitment();

        // only allow commitments for the first week
        if (block.timestamp > currentPeriodStart() + TimeLibrary.WEEK) revert TooLateCommitmentChange();

        uint32 periodJoined = getPeriodJoined(msg.sender);
        uint32 currentPeriod = currentPeriodId(); // gas

        // write to storage for all 0 values- as the $.currentCommitmentLevel is now different
        for (uint32 i = currentPeriod; i > periodJoined - 1; i--) {
            MemberDetail storage memberDetail = $.memberDetails[msg.sender][i];
            if (memberDetail.commitmentLevel == 0) {
                memberDetail.commitmentLevel = oldCommitment;
            } else {
                // we have reached the end of zero values
                break;
            }
        }

        $.currentCommitmentLevel[msg.sender] = newCommitmentLevel;
        $.sumCommitmentLevel = $.sumCommitmentLevel - uint128(oldCommitment) + uint128(newCommitmentLevel);

        emit ChangeCommitmentLevel({
            who: msg.sender,
            oldCommitment: oldCommitment,
            newCommitmentLevel: newCommitmentLevel
        });
    }

    // function canSeal(uint32 period) external view returns (bool) {
    //     PeriodSummary memory periodSummary = periodSummaries[period];
    //     if (periodSummary.isSealed) return false;
    //     uint256 length = members.length;
    //     for (uint256 i = 0; i < length; i++) {
    //         if (participations[members[i]][period].score == 0) {
    //             return false;
    //         }
    //     }
    //     return true;
    // }

    // TODO: role other than admin?
    // function seal(uint32 period) external {
    //     _revertForNotAdmin(msg.sender);
    //     PeriodSummary storage periodSummary = periodSummaries[period];
    //     if (periodSummary.isSealed) revert PeriodAlreadySealed();
    //     periodSummary.isSealed = true;
    // }
}
