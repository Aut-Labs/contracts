// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {INova} from "../../nova/interfaces/INova.sol";
import {IAutID} from "../../IAutID.sol";
import {IPlugin} from "../IPlugin.sol";

import "./ILocalReputation.sol";

/// @title Local Reputation Framework for ĀutID holders
contract LocalRep is ILocalReputation {
    /// @notice stores plugin-dao relation on initialization
    mapping(address plugin => address dao) public daoOfPlugin;

    /// @notice  stores Group State
    mapping(uint256 contextID => groupState) getGS;

    /// @notice  stores Individual State in Group
    mapping(uint256 contextID => individualState) getIS;

    /// @notice stores amount of points awared per interaction
    mapping(uint256 => uint256 points) public pointsPerInteraction;

    uint16 public immutable DEFAULT_K = 30;
    uint8 public immutable DEFAULT_PENALTY = 10;
    /// @dev unimplemented
    uint8 public immutable DEFAULT_CAP_GROWTH = 40;
    uint32 public immutable DEFAULT_PERIOD = 30 days;

    /////////////////////  Modifiers
    ///////////////////////////////////////////////////////////////
    modifier onlyPlugin() {
        //// @dev is this sufficient?
        if (daoOfPlugin[_msgSender()] == address(0)) revert Unauthorised();
        _;
    }

    //// @notice executed once when the plugin is installed per logic-nova pair
    function initialize(address nova_) external {
        uint256 context = getContextID(_msgSender(), nova_);

        context = getContextID(nova_, nova_);
        groupState memory Group = getGS[context];

        if (Group.lastPeriod != 0) return;

        Group.k = DEFAULT_K;
        Group.p = DEFAULT_PERIOD;
        Group.penalty = DEFAULT_PENALTY;
        Group.c = DEFAULT_CAP_GROWTH;

        Group.lastPeriod = uint64(block.timestamp);

        getGS[context] = Group;

        updateCommitmentLevels(nova_);

        daoOfPlugin[_msgSender()] = nova_;

        emit LocalRepInit(nova_, _msgSender());
    }

    //// @notice fetches commitment levels from AutID for a specific Nova and updates Total Commitment Level if needed
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

    /// @notice updates group state to latest to account for latest interactions
    function periodicGroupStateUpdate(address group_) public returns (uint256 nextUpdateAt) {
        uint256 context = getContextID(group_, group_);
        updateCommitmentLevels(group_);

        groupState memory gs = getGS[context];
        nextUpdateAt = gs.p + gs.lastPeriod;

        if (gs.lrUpdatesPerPeriod >= INova(group_).memberCount()) {
            gs.lastPeriod = uint64(block.timestamp);
            gs.TCP = 0;
            gs.lrUpdatesPerPeriod = 0;
            getGS[context] = gs;
            nextUpdateAt = block.timestamp + gs.p;

            emit EndOfPeriod();
        }
    }

    /// @notice updates local reputation of a specific individual context
    function updateIndividualLR(address who_, address group_) public returns (uint256) {
        uint256 Icontext = getContextID(who_, group_);
        uint256 Gcontext = getContextID(group_, group_);
        individualState memory ISS = getIS[Icontext];
        groupState memory GSS = getGS[Gcontext];

        if (ISS.lastUpdatedAt > GSS.lastPeriod) return ISS.score;
        /// @dev invariant GSS update always before ISS

        ISS.lastUpdatedAt = uint64(block.timestamp);
        if (ISS.score == 0) ISS.score = 1;
        if (GSS.TCL * GSS.TCP * GSS.k * ISS.score == 0) revert ZeroUnallawed();

        GSS.lrUpdatesPerPeriod += 1;
        getGS[Gcontext] = GSS;
        if (GSS.lrUpdatesPerPeriod >= INova(group_).memberCount()) periodicGroupStateUpdate(group_);

        ISS.score = calculateLocalReputation(ISS.GC, ISS.iCL, GSS.TCL, GSS.TCP, GSS.k, ISS.score, GSS.penalty);
        ISS.GC = 0;

        getIS[Icontext] = ISS;
        return uint256(ISS.score);
    }

    /// @notice pure function for calculating local reputation
    /// @param iGC individual given contribution
    /// @param TCL sum of all member commitment levels
    /// @param TCP total contribution points for group
    /// @param iCL individual commitment level
    /// @param k steepness degree or pace of reputation changes
    /// @param prevScore previous local reputation score
    /// @param penalty inactivity penalty as percentage (0-100). Default 10.
    function calculateLocalReputation(
        uint256 iGC,
        uint256 iCL,
        uint256 TCL,
        uint256 TCP,
        uint256 k,
        uint256 prevScore,
        uint256 penalty
    ) public pure returns (uint256 score) {
        if (k > 10_000) revert MaxK();
        if (iGC == 0 && prevScore > 0) {
            score = uint64(prevScore - ((prevScore * penalty) / 100));
        } else {
            uint256 fractionalCommitmentLevel = (iCL * 1 ether) / TCL;
            uint256 EC = fractionalCommitmentLevel * TCP;

            EC = EC == 0 ? 1 : EC;
            score = uint64((((iGC * 1 ether) / EC) * (100 - k) + k) * prevScore);
        }
        score = score / 1 ether == 0 ? score * (10 * (1 ether / score)) : score;
    }

    /// @dev consider dos vectors and changing return type
    /// @notice updates the local reputation of all members in the given nova
    /// @param group_ address of nova
    function bulkPeriodicUpdate(address group_) external returns (uint256[] memory localReputationScores) {
        uint256 context = getContextID(group_, group_);
        groupState memory startGS = getGS[context];
        if ((startGS.lastPeriod + startGS.p) > block.timestamp) revert PeriodUnelapsed();

        periodicGroupStateUpdate(group_);

        address[] memory members = INova(group_).getAllMembers();
        localReputationScores = new uint256[](members.length);
        uint256 i;
        for (i; i < members.length;) {
            localReputationScores[i] = updateIndividualLR(members[i], group_);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice sets number of points each function in contexts asigns to caller
    /// @param plugin_ plugin target
    /// @param datas_, array of selector encoded (msg.data) bytes
    /// @param points_, amount of points to be awared for each of datas_
    function setInteractionWeights(address plugin_, bytes[] memory datas_, uint256[] memory points_) external {
        if (daoOfPlugin[plugin_] == address(0)) revert UninitializedPair();
        if (!INova(daoOfPlugin[plugin_]).isAdmin(_msgSender())) revert OnlyAdmin();

        if (datas_.length != points_.length) revert ArgLenMismatch();
        uint256 interact;
        uint256 i;
        for (i; i < datas_.length;) {
            interact = interactionID(plugin_, datas_[i]);
            pointsPerInteraction[interact] = points_[i];
            unchecked {
                ++i;
            }
        }
        emit SetWeightsFor(plugin_, interact);
    }

    /// @notice called only by plugin implementing interaction modifier to apply points for successfu execution
    /// @param datas_ msg.data of called function
    /// @param callerAgent_ address that called the function to be rewarded
    function interaction(bytes memory datas_, address callerAgent_) external onlyPlugin {
        uint256 interactID = interactionID(_msgSender(), datas_);
        uint256 repPoints = pointsPerInteraction[interactID];
        address dao = daoOfPlugin[_msgSender()];

        getIS[getContextID(callerAgent_, dao)].GC += uint64(repPoints);
        getGS[getContextID(dao, dao)].TCP += uint64(repPoints);

        emit Interaction(interactID, callerAgent_);
    }

    /// @notice sets k and p for specific group
    /// @param k steepness degree for slope of local reputations score changes
    /// @param p min amount of time duration in seconds of period
    function setKP(uint16 k, uint32 p, uint16 penalty, address target_) external {
        if (!INova(target_).isAdmin(_msgSender())) revert OnlyAdmin();

        if (k * p == 0) revert ZeroUnallowed();
        if (((k / 100) + (p / 100)) > 0) revert Over100();
        ///@dev substitute with penalty not p

        uint256 context = getContextID(target_, target_);
        getGS[context].k = k;
        getGS[context].p = p;
        getGS[context].p = penalty;

        emit UpdatedKP(target_);
    }

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

    /// @notice get the individual state of a subject in a group
    /// @param subject_ address of the subject
    /// @param group_ address of the group
    function getLRof(address subject_, address group_) public view returns (individualState memory) {
        return getIS[getContextID(subject_, group_)];
    }

    function getReputationScore(address subject_, address group_) public view returns (uint256 score) {
        score = getLRof(subject_, group_).score;
    }

    /// @notice gets the agregated last updated state of reputation related nova data
    /// @param nova_ address of nova
    function getGroupState(address nova_) external view returns (groupState memory) {
        return getGS[getContextID(nova_, nova_)];
    }

    /// @notice gets the last updated state of reputation for individual agent in a nova
    /// @param agent_ address of agent
    /// @param nova_ address of nova
    function getIndividualState(address agent_, address nova_) external view returns (individualState memory) {
        return getIS[getContextID(agent_, nova_)];
    }

    /////////////////////  Pereiphery
    ///////////////////////////////////////////////////////////////
    /// @notice get the address of the sender
    /// @dev handle virtual sender if case
    function _msgSender() private view returns (address) {
        return msg.sender;
    }
}
