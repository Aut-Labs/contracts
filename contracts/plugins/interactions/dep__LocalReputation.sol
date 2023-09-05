// // SPDX-License-Identifier: UNLICENSED
// pragma solidity 0.8.18;

// import "forge-std/console.sol";

// import {INova} from "../../nova/interfaces/INova.sol";
// import {IAutID} from "../../IAutID.sol";

// /// @notice reputation
// contract LocalRep {
//     /// @notice stores entity authorisation to operate on LR
//     mapping(uint256 context => bool isAuthorised) public authorised;

//     /// @notice stores plugin-dao relation on initialization
//     /// @dev prevents external call
//     mapping(address plugin => address dao) public daoOfPlugin;

//     uint32 immutable defaultK = 30;
//     uint32 immutable defaultPeriod = 30 days;

//     /// @notice composed agent centered context ID
//     /// @dev 0 is reserved for global context
//     /// @dev groupAddress => is for group context
//     /// @dev contextID is composed of the sum of context + agent address
//     /// returns two LR instances for target: current state and last state

//     mapping(uint256 contextID => groupState) getGS;

//     mapping(uint256 contextID => individualState) getIS;

//     mapping(uint256 context => uint256[2] currNext ) currentNextPeriod;

//     struct groupState {
//         uint32 lastPeriod; //lastPeriod: Last period in which the LR was updated.
//         uint64 TCL; //TCL (Total Commitment Level in the Community): Sum of all members' Commitment Levels (between 1 and 10).
//         uint64 TCP; //TCP (Total Contributions Points in a Community): Sum of all contributions points, considering custom weights per interaction (between 1 and 10).
//         uint32 k; //  (Steepness Degree): Controls the slope of LR changes, initially fixed at 0.3, later customizable within 0.01 to 0.99: 0.01 ≤ k ≤ 0.99 | penalty
//         uint32 p; /// period duration in days
//     }

//     struct individualState {
//         uint32 iCL; //iCL (Commitment Level): Represents individual members' commitment, ranging from 1 to 10.
//         uint32 score; // Individual Local Reputation Score
//         uint64 GC; // GC (Given Contributions):Actual contributions made by a member. (points)
//         // uint64 EC; // EC (Expected Contributions): Calculated based on fCL and TCP.
//         // uint64 fCL; // fCL (Fractional Commitment Level per Individual): Fraction of total commitment attributed to each member.
//      }

//     event UpdatedKP(address targetGroup);

//     /////////////////////  Errors
//     ///////////////////////////////////////////////////////////////
//     error Unauthorised();
//     error Uninitialized();
//     error OnlyOnce();
//     error Over100();
//     error ZeroUnallowed();
//     error OnlyAdmin();
//     error UninitializedPair();

//     /////////////////////  Modifiers
//     ///////////////////////////////////////////////////////////////
//     modifier onlyAuthorised(address target) {

//         if (authorised[getContextID(msg.sender, target)]) {
//             _;
//             /// has been previously authorised
//         } else {
//             if (daoOfPlugin[msg.sender] == target) _;
//             else revert Unauthorised();
//             /// is a plugin of target instance, by default authorised
//         }
//     }

//     function initialize(address dao_) external {

//         uint256 context = getContextID(dao_, dao_);

//         LR memory uninitializedLR = getLR[context][0];

//         if ((uninitializedLR.k > 0)) revert OnlyOnce();

//         authorised[getContextID(msg.sender, dao_)] = true;
//         uninitializedLR.k = 30;
//         /// default k
//         uninitializedLR.p = defaultPeriod;
//         /// default p

//         currentNextPeriod[uint160(dao_)] = [block.timestamp, block.timestamp + defaultPeriod];

//         getLR[context][0] = uninitializedLR;

//         daoOfPlugin[dao_] = msg.sender;

//     }

//     function setInteractionWeights(address dao_, address plugin_, bytes4[] memory fxSigs, bytes[] memory datas) external {
//         if (! INova(dao_).isAdmin(msg.sender)) revert OnlyAdmin();
//         if (daoOfPlugin[plugin_] != dao_ ) revert UninitializedPair();

//     }

// event Interaction(bytes4 sig, bytes  data, address agent);

// function interaction(bytes4 fxSig, bytes memory data, address callerAgent) external onlyAuthorised(msg.sender) {
//     emit Interaction(fxSig, data, callerAgent);
// }

//     function setKP(uint16 k, uint16 p, address target_) external onlyAuthorised(target_) {
//         if (k * p == 0) revert ZeroUnallowed();
//         if (((k / 100) + (p / 100)) > 0) revert Over100();

//         uint256 context = getContextID(target_, target_);
//         getLR[context][0].k = k;
//         getLR[context][0].p = p;

//         emit UpdatedKP(target_);
//     }

//     /////////////////////  Public (onlyAuthorised)
//     ///////////////////////////////////////////////////////////////

//     //// @notice authorised agents to enact upon specific entity can authorise others
//     function setAuthorised(address agent_, address entity_, bool isAuthorised)
//         public
//         onlyAuthorised(entity_)
//         returns (bool)
//     {
//         return authorised[getContextID(agent_, entity_)] = isAuthorised;
//     }

//     /// @notice update the LR of a subject in a group
//     /// @param agent_ address of the subject
//     /// @param group_ address of the group
//     function updateAgentLR(address agent_, address group_) public onlyAuthorised(group_) returns (LR memory) {
//         uint256 agentContext = getContextID(agent_, group_);
//         LR[2] memory agentLRS = getLR[agentContext];

//         LR memory agentLR = agentLRS[0];
//         LR memory prevLR = agentLRS[1];
//         LR memory groupLR = getLR[uint160(group_)][0];

//         if (currentNextPeriod[uint160(group_)][1] == agentLR.lastPeriod) return agentLR; /// already executed
//         if (currentNextPeriod[uint160(group_)][1] != block.timestamp) _period(uint256(uint160(group_)));
//         agentLR.lastPeriod = uint32(block.timestamp);

//         /// @dev case where update for epoch in progress / executed for agent

//         //         struct LR {
//         //     uint64 lastPeriod; //lastPeriod: Last period in which the LR was updated.
//         //     uint64 iCL; //iCL (Commitment Level): Represents individual members' commitment, ranging from 1 to 10.
//         //     uint64 TCP; //TCP (Total Contributions Points in a Community): Sum of all contributions points, considering custom weights per interaction (between 1 and 10).
//         //     uint64 TCL; //TCL (Total Commitment Level in the Community): Sum of all members' Commitment Levels (between 1 and 10).
//         //     uint64 fCL; // fCL (Fractional Commitment Level per Individual): Fraction of total commitment attributed to each member.
//         //     uint64 EC; // EC (Expected Contributions): Calculated based on fCL and TCP.
//         //     uint64 GC; // GC (Given Contributions):Actual contributions made by a member. | @dev means what exactly
//         //     uint32 score;
//         //     uint16 k; //  (Steepness Degree): Controls the slope of LR changes, initially fixed at 0.3, later customizable within 0.01 to 0.99: 0.01 ≤ k ≤ 0.99 | penalty
//         //     uint16 p; // inter-period duration in days
//         // }

//         agentLRS[1] = agentLR;
//         agentLRS[0].score = calculateLR(agentLR, groupLR, prevLR);
//         agentLRS[0].lastPeriod = uint32(block.timestamp);
//     }

//     function _period(uint256 group) private {
//         currentNextPeriod[group] =
//             currentNextPeriod[group][0] == 0 ? [block.timestamp, block.timestamp + defaultPeriod ] : [currentNextPeriod[group][0], block.timestamp + defaultPeriod ];
//     }

//     // function sealPeriod(address group) external onlyAuthorised(group) {}

//     /////////////////////  Pure
//     ///////////////////////////////////////////////////////////////

//     /// @notice composed agent centered context ID
//     /// @param subject_ address of the subject
//     /// @param group_ address of the group
//     function getContextID(address subject_, address group_) public pure returns (uint256) {
//         return uint256(uint160(subject_)) + uint256(uint160(group_));
//     }

//     /////////////////////  View
//     ///////////////////////////////////////////////////////////////

//     /// @notice get the LR of a subject in a group
//     /// @param subject address of the subject
//     /// @param group address of the group
//     function getLRByAddress(address subject, address group) public view returns (LR memory) {
//         return getLR[getContextID(subject, group)][0];
//     }

//     /// @notice get LR score
//     /// @param agentAddress_ address of subject
//     /// @param groupAddress_ address of group
//     function getLRScore(address agentAddress_, address groupAddress_) public view returns (uint256) {
//         LR[2] memory agentLRS = getLR[getContextID(agentAddress_, groupAddress_)];
//         LR memory agentLR = agentLRS[0];
//         LR memory prevLR = agentLRS[1];

//         LR memory groupLR = getLR[getContextID(groupAddress_, groupAddress_)][0];

//         return calculateLR(agentLR, groupLR, prevLR);
//     }

//     function calculateLR(LR memory agentLR_, LR memory groupLR, LR memory prevLR) internal view returns (uint32) {
//         if (agentLR_.GC + prevLR.score == 0) return 0;
//         if (agentLR_.GC == 0) {
//             return prevLR.score * groupLR.p / 100;
//         }
//         return uint32((agentLR_.GC / (agentLR_.fCL / agentLR_.TCP)) * ((100 - groupLR.k) + groupLR.k) * prevLR.score);
//     }

//     function getK(address group_) external view returns (uint32) {
//         return getLR[getContextID(group_, group_)][0].k;
//     }

//     function getP(address group_) external view returns (uint32) {
//         return getLR[getContextID(group_,group_)][0].p;
//     }

//     /////////////////////  Pereiphery
//     ///////////////////////////////////////////////////////////////
//     /// @notice get the address of the sender
//     /// @dev handle virtual sender
//     function _msgSender() private view returns (address) {
//         return msg.sender;
//     }
// }
