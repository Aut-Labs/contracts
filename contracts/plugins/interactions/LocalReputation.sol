// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {INova} from "../../nova/interfaces/INova.sol";
import {IAutID} from "../../IAutID.sol";
import {IPlugin} from "../IPlugin.sol";
import "./ILocalReputation.sol";

/// @notice reputation
contract LocalRep {
    /// @notice stores entity authorisation to operate on LR
    mapping(uint256 context => bool isAuthorised) public authorised;

    /// @notice stores plugin-dao relation on initialization
    /// @dev prevents external call
    mapping(address plugin => address dao) public daoOfPlugin;

    uint32 public immutable DEFAULT_K = 30;
    uint32 public immutable DEFAULT_PERIOD = 30 days;

    mapping(uint256 contextID => groupState) getGS;

    mapping(uint256 contextID => individualState) getIS;

    mapping(uint256 => uint256 points) public pointsPerInteraction;

    event UpdatedKP(address targetGroup);
    event Interaction(uint256 InteractionID, address agent);
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
        if (daoOfPlugin[msg.sender] == address(0)) revert Unauthorised();
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

        updateCommitmentLevels(nova_);

        daoOfPlugin[msg.sender] = nova_;

        emit LocalRepInit(nova_, msg.sender);
    }

    function updateCommitmentLevels(address nova_) public {
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

    event SetWeightsFor(address plugin, uint256 interactionId);

    /// @notice sets number of points each function asigns
    /// @param plugin_ plugin target
    //
    function setInteractionWeights(address plugin_, bytes[] memory datas, uint256[] memory points) external {
        if (daoOfPlugin[plugin_] == address(0)) revert UninitializedPair();
        if (!INova(daoOfPlugin[plugin_]).isAdmin(msg.sender)) revert OnlyAdmin();

        if (datas.length != points.length) revert ArgLenMismatch();
        uint256 interact;
        uint256 i;
        for (i; i < datas.length;) {
            interact = interactionID(plugin_, datas[i]);
            pointsPerInteraction[interact] = points[i];
            unchecked {
                ++i;
            }
        }
        emit SetWeightsFor(plugin_, interact);
    }

    function interaction(bytes memory data, address callerAgent) external onlyPlugin {
        uint256 interactID = interactionID(msg.sender, data);
        uint256 repPoints = pointsPerInteraction[interactID];
        address dao = daoOfPlugin[msg.sender];

        getIS[getContextID(callerAgent, dao)].GC += uint64(repPoints);
        getGS[getContextID(dao, dao)].TCP += uint64(repPoints);

        emit Interaction(interactID, callerAgent);
    }

    function setKP(uint32 k, uint32 p, address target_) external {
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

    /// @notice context specific ID
    /// @param subject_ address of the subject
    /// @param group_ address of the group
    function getContextID(address subject_, address group_) public pure returns (uint256) {
        return uint256(uint160(subject_)) + uint256(uint160(group_));
    }

    /// @notice context specific ID
    /// @param plugin_ address of installed plugin
    /// @param data_ function calldata definitory of interaction
    /// @dev data_ is msg.data. encodeWithSignature for consistency
    function interactionID(address plugin_, bytes memory data_) public pure returns (uint256 id) {
        id = uint256(uint160(plugin_) + uint256(keccak256(data_)));
    }

    /////////////////////  View
    ///////////////////////////////////////////////////////////////

    /// @notice get the LR of a subject in a group
    /// @param subject_ address of the subject
    /// @param group_ address of the group
    function getLRof(address subject_, address group_) public view returns (individualState memory) {
        return getIS[getContextID(subject_, group_)];
    }

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

    // struct groupState {
    //     uint64 lastPeriod; //lastPeriod: Last period in which the LR was updated.
    //     uint64 TCL; //TCL (Total Commitment Level in the Community): Sum of all members' Commitment Levels (between 1 and 10).
    //     uint64 TCP; //TCP (Total Contributions Points in a Community): Sum of all contributions points, considering custom weights per interaction (between 1 and 10).
    //     uint32 k; //  (Steepness Degree): Controls the slope of LR changes, initially fixed at 0.3, later customizable within 0.01 to 0.99: 0.01 ≤ k ≤ 0.99 | penalty
    //     uint32 p;

    //     bytes32 commitHash;
    // }

    // struct individualState {
    //     uint32 iCL; //iCL (Commitment Level): Represents individual members' commitment, ranging from 1 to 10.
    //     uint32 score; // Individual Local Reputation Score
    //     uint64 GC; // GC (Given Contributions):Actual contributions made by a member. (points)
    //     uint64 lastUpdatedAt;

    //         // uint64 EC; // EC (Expected Contributions): Calculated based on fCL and TCP.
    //         // uint64 fCL; // fCL (Fractional Commitment Level per Individual): Fraction of total commitment attributed to each member.
    // }

    function periodicGroupStateUpdate(address group_) public returns (uint256 nextUpdateAt) {
        uint256 context = getContextID(group_, group_);
        updateCommitmentLevels(group_);

        groupState memory gs = getGS[context];
        nextUpdateAt = gs.p + gs.lastPeriod;
        if (nextUpdateAt > block.timestamp) return nextUpdateAt;
        nextUpdateAt = block.timestamp + gs.p;
        gs.lastPeriod = uint64(block.timestamp);
        getGS[context] = gs;
    }

    function updateIndividualLR(address who_, address group_) public returns (uint256 lr) {
        uint256 Icontext = getContextID(who_, group_);
        uint256 Gcontext = getContextID(group_, group_);
        individualState memory ISS = getIS[Icontext];
        groupState memory GSS = getGS[Gcontext];
        if (ISS.lastUpdatedAt < GSS.lastPeriod) return ISS.score;

        ISS.score = uint32((ISS.GC / (((ISS.GC * 100_00) / GSS.TCL) / GSS.TCP)) * ((100 - GSS.k) + GSS.k) * ISS.score);
    }

    function getGroupState(address nova_) external view returns (groupState memory) {
        return getGS[getContextID(nova_, nova_)];
    }

    function getIndividualState(address agent_, address nova_) external view returns (individualState memory) {
        return getIS[getContextID(agent_, nova_)];
    }

    function isAuthorised(address who_, address onWhat_) external view returns (bool) {
        return authorised[getContextID(who_, onWhat_)];
    }

    /////////////////////  Pereiphery
    ///////////////////////////////////////////////////////////////
    /// @notice get the address of the sender
    /// @dev handle virtual sender
    function _msgSender() private view returns (address) {
        return msg.sender;
    }
}
