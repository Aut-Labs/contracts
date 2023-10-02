// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {INova} from "./nova/interfaces/INova.sol";
import {IAutID} from "./IAutID.sol";
import {IPlugin} from "./plugins/IPlugin.sol";

import "./ILocalReputation.sol";
/// @title Local Reputation Framework for ĀutID holders

contract LocalReputation is ILocalReputation {
    /// @notice stores plugin(or authorised address)-dao relation on initialization
    mapping(address plugin => address dao) public daoOfPlugin;

    /// @notice  stores Group State
    mapping(uint256 contextID => groupState) getGS;

    /// @notice  stores Individual State in Group
    mapping(uint256 contextID => individualState) getIS;

    /// @notice stores amount of points awared per interaction
    mapping(uint256 => uint16 points) public pointsPerInteraction;

    uint16 public immutable DEFAULT_K = 30;
    uint8 public immutable DEFAULT_PENALTY = 40;
    uint8 public immutable DEFAULT_CAP_GROWTH = 40;
    uint32 public immutable DEFAULT_PERIOD = 30 days;

    /////////////////////  Modifiers
    ///////////////////////////////////////////////////////////////
    modifier onlyPlugin() {
        //// @dev is this sufficient?
        if (daoOfPlugin[_msgSender()] == address(0)) revert Unauthorised();
        _;
    }

    //// @notice executed once
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
    function updateCommitmentLevels(address nova_) public returns (uint256[] memory commitments) {
        INova Nova = INova(nova_);
        IAutID AutID = IAutID(Nova.getAutIDAddress());

        address[] memory members = IAutID(INova(nova_).getAutIDAddress()).getAllActiveMembers(nova_);
        if (members.length == 0) return commitments;
        commitments = AutID.getCommitmentsOfFor(members, nova_);
        bytes32 currentCommitment = keccak256(abi.encodePacked(commitments));
        uint256 context = getContextID(nova_, nova_);

        if (currentCommitment == getGS[context].commitHash) return commitments;

        groupState memory gs = getGS[context];

        gs.commitHash = currentCommitment;
        uint256 totalCommitment;
        uint256 i;

        for (i; i < commitments.length;) {
            getIS[getContextID(members[i], nova_)].iCL = uint32(commitments[i]);
            totalCommitment += commitments[i];
            unchecked {
                ++i;
            }
        }

        gs.TCL = uint64(totalCommitment);

        gs.periodNovaParameters.aDiffMembersLP =
            int32(int256(members.length) - int256(getGS[context].periodNovaParameters.bMembersLastLP));
        gs.periodNovaParameters.dAverageCommitmentLP = uint32(totalCommitment / members.length);

        getGS[context] = gs;
    }

    /// @notice updates group state to latest to account for latest interactions
    /// @param group_ target address to update group state for
    function periodicGroupStateUpdate(address group_) public returns (uint256 nextUpdateAt) {
        uint256 context = getContextID(group_, group_);
        uint256 membersLen = updateCommitmentLevels(group_).length;

        groupState memory gs = getGS[context];
        nextUpdateAt = gs.p + gs.lastPeriod;

        if (gs.lrUpdatesPerPeriod >= INova(group_).memberCount()) {
            gs.lastPeriod = uint64(block.timestamp);
            gs.lrUpdatesPerPeriod = 0;
            gs.periodNovaParameters.ePerformanceLP = gs.TCP > 0
                ? uint64(pointsPerInteraction[getContextID(group_, group_)] * membersLen * 1 ether / gs.TCP)
                : 1 ether;
            gs.TCP = 0;
            getGS[context] = gs;
            nextUpdateAt = block.timestamp + gs.p;

            emit EndOfPeriod();
        }
    }

    /// @notice updates local reputation of a specific individual context
    /// @param who_ agent address to update local reputation for
    /// @param group_ target group context for local repuatation update
    function updateIndividualLR(address who_, address group_) public returns (uint256) {
        if (!INova(group_).isAdmin(_msgSender())) revert Unauthorised();
        uint256 Icontext = getContextID(who_, group_);
        uint256 Gcontext = getContextID(group_, group_);
        individualState memory ISS = getIS[Icontext];
        groupState memory GSS = getGS[Gcontext];

        if (ISS.lastUpdatedAt > GSS.lastPeriod) return ISS.score;

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
            prevScore = prevScore == 0 ? 1 ether : prevScore;
            score = uint64((((iGC * 1 ether) / EC) * (100 - k) + k) * prevScore);
            score = score / 1 ether == 0 ? score * (10 * (1 ether / score)) : score / 100;
            if (score > 10 ether) score = 10 ether;
            if (((prevScore + (prevScore / 100 * 40)) < score) && (prevScore != 1)) {
                score = prevScore + ((prevScore / 100) * 40);
            }
        }
    }

    /// @dev consider dos vectors and changing return type
    /// @notice updates the local reputation of all members in the given nova
    /// @param group_ address of nova
    function bulkPeriodicUpdate(address group_) external returns (uint256[] memory localReputationScores) {
        uint256 context = getContextID(group_, group_);
        groupState memory startGS = getGS[context];
        if ((startGS.lastPeriod + startGS.p) > block.timestamp) revert PeriodUnelapsed();

        periodicGroupStateUpdate(group_);

        address[] memory members = IAutID(INova(group_).getAutIDAddress()).getAllActiveMembers(group_);
        localReputationScores = new uint256[](members.length);
        uint256 sumLR;
        uint256 i;
        for (i; i < members.length;) {
            localReputationScores[i] = updateIndividualLR(members[i], group_);
            sumLR += localReputationScores[i];

            unchecked {
                ++i;
            }
        }
        sumLR = sumLR / members.length;
        getGS[context].periodNovaParameters.cAverageRepLP = uint64(sumLR);
        getGS[context].periodNovaParameters.bMembersLastLP = int32(int64(int256(members.length)));
    }

    /// @notice sets number of points each function in contexts asigns to caller
    /// @param plugin_ plugin target
    /// @param datas_, array of selector encoded (msg.data) bytes
    /// @param points_, amount of points to be awared for each of datas_, 0 to remove and readjust for performance
    function setInteractionWeights(address plugin_, bytes[] memory datas_, uint16[] memory points_) external {
        if (daoOfPlugin[plugin_] == address(0)) revert UninitializedPair();
        address nova = daoOfPlugin[plugin_];
        if (!(INova(nova).isAdmin(_msgSender())) && (_msgSender() != plugin_)) revert OnlyAdmin();
        if (datas_.length != points_.length) revert ArgLenMismatch();
        uint256 interact;
        uint256 i;

        for (i; i < datas_.length;) {
            interact = interactionID(plugin_, datas_[i]);
            if (points_[i] > 1_000) revert k1MaxPointPerInteraction();
            pointsPerInteraction[interact] = points_[i];

            (pointsPerInteraction[interact] > 0 && points_[i] == 0)
                ? pointsPerInteraction[getContextID(nova, nova)] -= pointsPerInteraction[interact]
                : pointsPerInteraction[getContextID(nova, nova)] += points_[i];
            unchecked {
                ++i;
            }
        }
        emit SetWeightsFor(plugin_, interact);
    }

    /// @notice called only by plugin implementing interaction modifier to apply points for successfu execution
    /// @param datas_ msg.data of called function
    /// @param callerAgent_ address that called the function to be rewarded
    function interaction(bytes calldata datas_, address callerAgent_) external onlyPlugin {
        uint256 interactID = interactionID(_msgSender(), datas_);
        uint256 repPoints = pointsPerInteraction[interactID];

        if (datas_.length == 2) repPoints = uint16(bytes2(datas_[:2]));

        if (repPoints == 0) return;
        address dao = daoOfPlugin[_msgSender()];

        getIS[getContextID(callerAgent_, dao)].GC += uint64(repPoints);
        getGS[getContextID(dao, dao)].TCP += uint64(repPoints);

        emit Interaction(interactID, callerAgent_);
    }

    /// @notice sets k and p for specific group
    /// @param k steepness degree for slope of local reputations score changes
    /// @param p min amount of time duration in seconds of period
    /// @param penalty penalty rate for
    function setKP(uint16 k, uint32 p, uint8 penalty, address target_) external {
        if (!INova(target_).isAdmin(_msgSender())) revert OnlyAdmin();

        if (k * p == 0) revert ZeroUnallowed();
        if (((k / 100) + (p / 100) + (penalty / 100)) > 0) revert Over100();
        ///@dev substitute with penalty not p

        uint256 context = getContextID(target_, target_);
        getGS[context].k = k;
        getGS[context].p = p;
        getGS[context].penalty = penalty;

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

    /// @notice get the local reputation score of an agent withoin a specified group.
    /// @dev defaut value is 1 ether. Score should be parsed as ether with two decimals in expected range (0.01 - 9.99)
    /// @param subject_ address of target agent
    /// @param group_ address of nova instance
    function getLocalReputationScore(address subject_, address group_) public view returns (uint256 score) {
        score = getLRof(subject_, group_).score;
        if (score == 0) score = 1 ether;
    }

    /// @notice gets the agregated last updated state of reputation related nova data
    /// @param nova_ address of nova
    function getGroupState(address nova_) external view returns (groupState memory) {
        return getGS[getContextID(nova_, nova_)];
    }

    /// @notice gets nova dynamic descriptive data updated at last period
    /// @param nova_ address of target group
    /// @dev data is lifecycle dependent
    /// @return array of integers: [difference in member nr. between periods | how many members last period | avg. reputation | avg. commitment ]
    function getPeriodNovaParameters(address nova_) external view returns (periodData memory) {
        return getGS[getContextID(nova_, nova_)].periodNovaParameters;
    }

    /// @notice returns average reputation and commitments
    /// @param nova_ address of group
    /// @return sumCommit sumRep tuple (commitment sum, reputation sum)
    function getAvReputationAndCommitment(address nova_) external view returns (uint256 sumCommit, uint256 sumRep) {
        address[] memory members = IAutID(INova(nova_).getAutIDAddress()).getAllActiveMembers(nova_);

        uint256 i;

        uint256[] memory commitments = IAutID(INova(nova_).getAutIDAddress()).getCommitmentsOfFor(members, nova_);

        for (i; i < members.length;) {
            sumRep += getIS[getContextID(members[i], nova_)].score;
            sumCommit += commitments[i];
            unchecked {
                ++i;
            }
        }
        sumCommit = sumCommit / members.length;
        sumRep = sumRep / members.length;
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
