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

    uint32 immutable DEFAULT_K = 30;
    uint32 immutable DEFAULT_PERIOD = 30 days;

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

        _updateCommitmentLevels(nova_);

        daoOfPlugin[msg.sender] = nova_;

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


    event SetWeightsFor(address plugin, uint256 interactionId);

    /// @notice sets number of points each function asigns
    /// @param plugin_ plugin target
    //
    function setInteractionWeights(
        address plugin_,
        bytes[] memory datas,
        uint256[] memory points
    ) external {
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

        emit Interaction( interactID, callerAgent);
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

    function interactionID(address plugin_, bytes memory data_) public pure returns (uint256 id) {
        id = uint256( uint160(plugin_) + uint256(keccak256(data_)) );
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


    function getGroupState(address nova_) external view returns (groupState memory ) {
        return getGS[getContextID(nova_, nova_)];
    }

    function getIndividualState(address agent_, address nova_) external view returns (individualState memory ) {
        return getIS[getContextID(agent_, nova_)];
    }

    /////////////////////  Pereiphery
    ///////////////////////////////////////////////////////////////
    /// @notice get the address of the sender
    /// @dev handle virtual sender
    function _msgSender() private view returns (address) {
        return msg.sender;
    }
}
