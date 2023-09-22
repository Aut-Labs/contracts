//SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.19;

/**
 * @title IPluginRegistry
 * @dev Interface for local reputation algorythm
 */

struct archetypeD {
    int64 aDiffMembersLP; // difference in member nr. between periods
    int64 bMembersLastLP; // how many members last period 
    uint64 cAverageRepLP; // avg. reputation
    uint64 dAverageCommitmentLP; // avg. commitment
    uint64 ePerformanceLP;
    uint64 fAllPoints;
    uint64 gPointsUsed;
}

struct groupState {
    uint64 lastPeriod; //lastPeriod: Last period in which the LR was updated.
    uint64 TCL; //TCL (Total Commitment Level in the Community): Sum of all members' Commitment Levels (between 1 and 10).
    uint64 TCP; //TCP (Total Contributions Points in a Community): Sum of all contributions points, considering custom weights per interaction (between 1 and 10).
    uint16 k; //  (Steepness Degree): Controls the slope of LR changes, initially fixed at 0.3, later customizable within 0.01 to 0.99: 0.01 ≤ k ≤ 0.99 | penalty
    uint8 penalty;
    uint8 c; // growth cap per period 1.4 40% default
    uint32 p; // period length
    bytes32 commitHash;
    uint256 lrUpdatesPerPeriod; // how many iS updates were executed // used to zero TCP // ensures LRs updated
    archetypeD archetypeData;
}



struct individualState {
    uint64 iCL; //iCL (Commitment Level): Represents individual members' commitment, ranging from 1 to 10.
    uint64 GC; // GC (Given Contributions):Actual contributions made by a member. (points)
    uint256 score; // Individual Local Reputation Score
    uint256 lastUpdatedAt;
}

interface ILocalReputation {
    /////////////////////  Events
    ///////////////////////////////////////////////////////////////

    event SetWeightsFor(address plugin, uint256 interactionId);
    event UpdatedKP(address targetGroup);
    event Interaction(uint256 InteractionID, address agent);
    event LocalRepInit(address Nova, address PluginAddr);
    event EndOfPeriod();

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
    error PeriodUnelapsed();
    error ZeroUnallawed();
    error MaxK();

    function initialize(address dao_) external;

    function interaction(bytes calldata msgData, address agent) external;

    function setInteractionWeights(address plugin_, bytes[] memory datas, uint8[] memory points) external;

    function getGroupState(address nova_) external view returns (groupState memory);

    function getIndividualState(address agent_, address nova_) external view returns (individualState memory);

    function setKP(uint16 k, uint32 p, uint16 penalty, address target_) external;

    function updateCommitmentLevels(address nova_) external;

    function updateIndividualLR(address who_, address group_) external returns (uint256);
    function periodicGroupStateUpdate(address group_) external returns (uint256 nextUpdateAt);

    function getArchetypeData(address nova_) external view returns (archetypeD memory);

    function getAvReputationAndCommitment(address nova_) external view returns (uint256 sumCommit, uint256 sumRep);

    function calculateLocalReputation(
        uint256 iGC,
        uint256 iCL,
        uint256 TCL,
        uint256 TCP,
        uint256 k,
        uint256 prevScore,
        uint256 penalty
    ) external pure returns (uint256 score);

    function bulkPeriodicUpdate(address group_) external returns (uint256[] memory localReputationScores);
}
