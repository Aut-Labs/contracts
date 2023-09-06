//SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.18;

/**
 * @title IPluginRegistry
 * @dev Interface for local reputation algorythm
 */

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

interface ILocalReputation {
    /// @notice function for setting dao specific reputation varibales
    /// @param dao_ address to which the plugin applies
    /// @dev
    function initialize(address dao_) external;

    /// @notice interaction function
    function interaction( bytes calldata msgData, address agent) external;

function setInteractionWeights(
        address plugin_,
        bytes[] memory datas,
        uint256[] memory points
    ) external;

    function getGroupState(address nova_) external view returns (groupState memory );

    function getIndividualState(address agent_, address nova_) external view returns (individualState memory);


}
