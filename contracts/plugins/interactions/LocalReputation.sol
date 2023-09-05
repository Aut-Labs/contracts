// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "forge-std/console.sol";

import {INova} from "../../nova/interfaces/INova.sol";
import {IAutID} from "../../IAutID.sol";
import {IPlugin} from "../IPlugin.sol";

/// @notice reputation
contract LocalRep {
    /// @notice stores entity authorisation to operate on LR
    mapping(uint256 context => bool isAuthorised) public authorised;

    /// @notice stores plugin-dao relation on initialization
    /// @dev prevents external call
    mapping(address plugin => address dao) public daoOfPlugin;

    uint32 immutable DEFAULT_K = 30;
    uint32 immutable DEFAULT_PERIOD = 30 days;

    mapping(uint256 contextID => groupState) getGS;

    mapping(uint256 contextID => individualState) getIS;

    mapping(uint256 => uint256 points) public pointsPerInteraction;

    struct groupState {
        uint64 lastPeriod; //lastPeriod: Last period in which the LR was updated.
        uint64 TCL; //TCL (Total Commitment Level in the Community): Sum of all members' Commitment Levels (between 1 and 10).
        uint64 TCP; //TCP (Total Contributions Points in a Community): Sum of all contributions points, considering custom weights per interaction (between 1 and 10).
        uint32 k; //  (Steepness Degree): Controls the slope of LR changes, initially fixed at 0.3, later customizable within 0.01 to 0.99: 0.01 ≤ k ≤ 0.99 | penalty
        uint32 p;
        /// period duration in days
        bytes32 commitHash;
    }

    struct individualState {
        uint32 iCL; //iCL (Commitment Level): Represents individual members' commitment, ranging from 1 to 10.
        uint32 score; // Individual Local Reputation Score
        uint64 GC; // GC (Given Contributions):Actual contributions made by a member. (points)
            // uint64 EC; // EC (Expected Contributions): Calculated based on fCL and TCP.
            // uint64 fCL; // fCL (Fractional Commitment Level per Individual): Fraction of total commitment attributed to each member.
    }

    event UpdatedKP(address targetGroup);
    event Interaction(bytes4 sig, bytes data, address agent);
    event LocalRepInit(address Nova, address PluginAddr);

    /////////////////////  Errors
    ///////////////////////////////////////////////////////////////
    error Unauthorised();
    error Uninitialized();
    error OnlyOnce();
    error Over100();
    error ZeroUnallowed();
    error OnlyAdmin();
    error UninitializedPair();
    error ArgLenMismatch();

    /////////////////////  Modifiers
    ///////////////////////////////////////////////////////////////
    modifier onlyPlugin() {
        //// @dev is this sufficient?
        if (daoOfPlugin[msg.sender] != address(0)) revert Unauthorised();
        _;
    }

    function initialize(address nova_) external {
        uint256 context = getContextID(msg.sender, nova_);
        authorised[context] = true;

        context = getContextID(nova_, nova_);
        groupState memory Group = getGS[context];
        if (Group.lastPeriod != 0) return;
        /// only first

        Group.k = DEFAULT_K;
        Group.p = DEFAULT_PERIOD;
        Group.lastPeriod = uint64(block.timestamp);

        getGS[context] = Group;

        _updateCommitmentLevels(nova_);

        daoOfPlugin[nova_] = msg.sender;

        emit LocalRepInit(nova_, msg.sender);
    }

    function _updateCommitmentLevels(address nova_) internal {
        INova Nova = INova(nova_);
        IAutID AutID = IAutID(Nova.getAutIDAddress());

        address[] memory members = Nova.getAllMembers();
        uint256[] memory commitments = AutID.getCommitmentsOfFor(members, nova_);
        bytes32 currentCommitment = keccak256(abi.encodePacked(commitments));
        uint256 context = getContextID(nova_, nova_);

        if (currentCommitment == getGS[context].commitHash) return;

        getGS[context].commitHash = currentCommitment;
        uint256 totalCommitment;
        uint256 i;

        for (i; i < commitments.length;) {
            getIS[getContextID(members[i], nova_)].iCL = uint32(commitments[i]);
            totalCommitment += commitments[i];
            unchecked {
                ++i;
            }
        }
        getGS[context].TCL = uint64(totalCommitment);
    }

    /// @notice sets number of points each function asigns
    /// @param plugin_ plugin target
    //
    function setInteractionWeights(
        address plugin_,
        bytes4[] memory fxSigs,
        bytes[] memory datas,
        uint256[] memory points
    ) external {
        if (daoOfPlugin[plugin_] == address(0)) revert UninitializedPair();
        if (!INova(daoOfPlugin[plugin_]).isAdmin(msg.sender)) revert OnlyAdmin();

        if (fxSigs.length != datas.length && points.length != fxSigs.length) revert ArgLenMismatch();
        uint256 i;
        for (i; i < fxSigs.length;) {
            uint256 interaction = interactionID(plugin_, fxSigs[i], datas[i]);
            pointsPerInteraction[interaction] = points[i];
            unchecked {
                ++i;
            }
        }
    }

    function interaction(bytes4 fxSig, bytes memory data, address callerAgent) external onlyPlugin {
        uint256 repPoints = pointsPerInteraction[interactionID(msg.sender, fxSig, data)];
        address dao = daoOfPlugin[msg.sender];

        getIS[getContextID(callerAgent, dao)].GC += uint64(repPoints);
        getGS[getContextID(dao, dao)].TCP += uint64(repPoints);

        emit Interaction(fxSig, data, callerAgent);
    }

    function interactionID(address plugin_, bytes4 fxsig_, bytes memory data_) public pure returns (uint256 id) {
        id = uint256(uint160(plugin_) + uint160(uint32(fxsig_)));
        if (data_.length > 0) id += uint256(keccak256(data_));
    }

    function setKP(uint16 k, uint16 p, address target_) external {
        if (!INova(target_).isAdmin(msg.sender)) revert OnlyAdmin();

        if (k * p == 0) revert ZeroUnallowed();
        if (((k / 100) + (p / 100)) > 0) revert Over100();

        uint256 context = getContextID(target_, target_);
        getGS[context].k = k;
        getGS[context].p = p;

        emit UpdatedKP(target_);
    }

    /////////////////////  Public (onlyAuthorised)
    ///////////////////////////////////////////////////////////////

    // function sealPeriod(address group) external onlyAuthorised(group) {}

    /////////////////////  Pure
    ///////////////////////////////////////////////////////////////

    /// @notice composed agent centered context ID
    /// @param subject_ address of the subject
    /// @param group_ address of the group
    function getContextID(address subject_, address group_) public pure returns (uint256) {
        return uint256(uint160(subject_)) + uint256(uint160(group_));
    }

    /////////////////////  View
    ///////////////////////////////////////////////////////////////

    // /// @notice get the LR of a subject in a group
    // /// @param subject address of the subject
    // /// @param group address of the group
    // function getLRByAddress(address subject, address group) public view returns (LR memory) {

    // }

    // /// @notice get LR score
    // /// @param agentAddress_ address of subject
    // /// @param groupAddress_ address of group
    // function getLRScore(address agentAddress_, address groupAddress_) public view returns (uint256) {
    //     LR[2] memory agentLRS = getLR[getContextID(agentAddress_, groupAddress_)];
    //     LR memory agentLR = agentLRS[0];
    //     LR memory prevLR = agentLRS[1];

    //     LR memory groupLR = getLR[getContextID(groupAddress_, groupAddress_)][0];

    //     return calculateLR(agentLR, groupLR, prevLR);
    // }

    // function calculateLR(LR memory agentLR_, LR memory groupLR, LR memory prevLR) internal view returns (uint32) {
    //     if (agentLR_.GC + prevLR.score == 0) return 0;
    //     if (agentLR_.GC == 0) {
    //         return prevLR.score * groupLR.p / 100;
    //     }
    //     return uint32((agentLR_.GC / (agentLR_.fCL / agentLR_.TCP)) * ((100 - groupLR.k) + groupLR.k) * prevLR.score);
    // }

    // function getK(address group_) external view returns (uint32) {
    //     return getLR[getContextID(group_, group_)][0].k;
    // }

    // function getP(address group_) external view returns (uint32) {
    //     return getLR[getContextID(group_,group_)][0].p;
    // }

    /////////////////////  Pereiphery
    ///////////////////////////////////////////////////////////////
    /// @notice get the address of the sender
    /// @dev handle virtual sender
    function _msgSender() private view returns (address) {
        return msg.sender;
    }
}
