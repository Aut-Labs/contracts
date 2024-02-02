// //SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// interface IInteractionCallArgsDecoder {
//     function decodeCallArgs(bytes memory callArgs) external returns(uint128 scenario, uint128 weight);
// }

// interface IInteractionLimiter {
//     function applyLimits(bytes32 interactionType, address member, uint128 quantity) external view returns(uint128 adjusted);
// }

// contract StubInteractionLimiter is IInteractionLimiter {
//     function applyLimits(bytes32 interactionType, address member, uint128 quantity) external view returns(uint128 adjustedQuantity) {
//         return quantity;
//     }
// }

// interface IInteractionDecoder {
//     function decodeInteraction(address sender, address targetContract, bytes4 targetSelector, bytes calldata args) external view returns(bytes32, uint128) {

//     }
// }

// contract CallArgsAgnosticInteractionDecoder is IInteractionDecoder {
//     function decodeInteraction(address sender, address target, bytes4 selector, bytes calldata) external pure returns(bytes32) {
//         return keccak256(abi.encodePacked(target, selector));
//     }
// }

// interface IInteractionWhitelist {
//     function isWhitelistedTarget(address targetContract) external view returns(bool);
// }

// interface IApplicationRegistry {
//     function isNovaApplication(address nova, address app) external view returns(bool);
// }

// interface INovaBase {
//     function applicationRegistry() external view returns(IApplicationRegistry);
// }

// contract InteractionTracker {
//     // interactions are independent from each other
//     // interactions are quantified (and act as integers with + operation further on)
//     // (so given contribution points can't depend on previous interactions and so on (exception -- interaction limiter))
//     address nova;

//     address interactionDecoder;
//     address interactionLimiter;

//     function processInteraction(
//         address caller,
//         bytes4 targetSelector,
//         bytes calldata args
//     ) public {
//         address targetContract = msg.sender;
//         if (!INova(nova).applicationRegistry().isNovaApplication(nova, targetContract)) {
//             /// decline if not a nova app
//             /// any nova app is able to report interactions to the same nova's interaction tracker
//             revert();
//         }
//         (bytes32 interactionType, uint128 quantified) = IInteractionDecoder(interactionDecoder).decodeInteraction(caller, targetContract, targetSelector, args);
//         if (interactionType == bytes32(0)) {
//             /// raise
//             revert();
//         }
//         uint128 adjustedQuantity = IInteractionLimiter(interactionLimiter).applyLimits(interacitonType, caller, quantified);
//         _handleContributionsGiven(caller, adjustedQuantity);
//     }

//     function _handleContributionGiven(address member, uint128 amount) internal {}
// }

// contract LocalReputationProcessor {
//     uint128 internal constant CORRECTION_MAGNITUDE = 1 << 16;

//     struct TContributionEntry {
//         uint128 timestamp;
//         uint128 points;
//         address member;
//     }

//     struct TMemberCommitmentEntry {
//         uint128 timestamp;
//         int128 commitmentDiff;
//         address member;
//         bool isNew;
//     }

//     struct TIndividualStats {
//         uint128 reputation;
//     }

//     TContributionEntry[] internal _queuedContributions;
//     TMemberCommitmentEntry[] internal _queuedMemberCommitmentChanges;

//     bool public valuationFlow;

//     mapping(uint128 => mapping(address => uint128)) memberContributionsByPeriod;
//     mapping(uint128 => uint256) memberCountByPeriod;
//     mapping(uint128 => uint256) totalCommitmentByPeriod;
//     mapping(address => uint128) correctionPercentByMember;

//     mapping(address => uint256) commitmentByMember;

//     mapping(uint128 => mapping(address => TIndividualState)) individualStatsByPeriod;
//     uint128 pendingMembers;

//     uint128 periodDuration;
//     uint128 periodStartTimestamp;
//     uint128 periodId;

//     function switchToValuationFlow() public {
//         if (valuationFlow) {
//             revert();
//         }
//         valuationFlow = true;
//     }

//     function switchToAquisitionFlow() public {
//         if (!valuationFlow) {
//             revert();
//         }
//         valuationFlow = false;
//         _processQueued();
//     }

//     function setIndividualStats(address member) public {
//         TIndividualStats memory stats = individualStatsByPeriod[periodId][member];
//         if (stats.reputation == 0) {
//             _finalizeStats(member);
//             --pendingMembers;
//         }
//     }

//     function setIndividualStatsBulk(address[] memory members) external {
//         for (uint256 i; i != members.length; ++i) {
//             if (gasleft() < 100_000)  { // todo: const {
//                 break;
//             }
//             setIndividualStats(members[i]);
//         }
//     }

//     function processMemberJoin(address member, uint256 commitmentLevel) external {
//         if (!valuationFlow) {
//             memberCountByPeriod[periodId]++;
//             totalCommitmentByPeriod[periodId] += commitmentLevel;
//             uint128 correctionPercent = (periodStartTimestamp + periodDuration - uint128(block.timestamp)) * 100 / periodDuration;
//             correctionPercentByMember[member] = correctionPercent; // adjust for the part of the perriod that was missed by new member
//             ++pendingMembers;
//         } else {
//             TMemberCommitmentEntry memory e;
//             e.timestamp = uint128(block.timestamp);
//             e.commitmentDiff = int128(commitmentLevel);
//             e.isNew = true;
//             e.member = member;
//             _queuedMemberCommitmentChanges.push(e);
//         }
//     }

//     function processContribution(address member, uint128 quantity) external {
//         if (valuationFlow) {
//             TContributionEntry memory contribution;
//             contribution.timestamp = block.timestamp;
//             contribution.points = quantity;
//             contribution.member = member;
//             _queuedContributions.push(contribution);
//         } else {
//             memberContributionsByPeriod[periodId][member] += quantity;
//         }
//     }

//     function _processQueued() internal {
//         uint256 contributionsPtr = 0;
//         uint256 commitmentPtr = 0;
//         uint256 contributionsLength = _queuedContributions.length;
//         uint256 commitmentsLength = _queuedMemberCommitmentChanges.length;

//         while (contributionsPtr != contributionsLength || commitmentPtr != commitmentLength) {
//             uint128 conTs = contributionsPtr == contributionsLength ? type(uint128).max : _queuedContributions[contributionsPtr].timestamp;
//             uint128 comTx = commitmentsPtr == commitmentsLength ? type(uint128).max : _queuedMemberCommitmentChanges[commitmentPtr].timestamp;
//             if (conTs <= comTx) {
//                 _processQueuedContribution();
//                 ++contributionsPtr;
//             } else {
//                 _processQueuedCommitment();
//                 ++commitmentPtr;
//             }
//         }
//     }
// }

// // contract NovaInteractionsSetupAndRuntime {

// //     // static interaction weight
// //     // non-dependent interaction weight (single tx)

// //     uint128 internal constant _SECONDS_PER_ANNUM = 60 * 60 * 24 * 30 * 12;

// //     struct TConfigData {
// //         uint128 baseWeight;
// //     }

// //     struct TThrottler {
// //         uint128 cooldownDuration;
// //         uint128 invocationsCountAnnualThreshold;
// //         uint128 processingEnabledAt;
// //     }

// //     struct TInteractionProcessData {
// //         uint128 invocationsCount;
// //         uint128 lastInvocationTimestamp;
// //     }

// //     mapping(bytes32 => TInteractionSetupData) internal _setupDataByHash;
// //     mapping(bytes32 => TInteractionProcessData) internal _processDataByHash;
// //     mapping(address => uint128) internal _pendingScoreBySender;
// //     mapping(bytes24 => address) internal _callArgsDecoderByTarget;

// //     function calcInteractionHash(
// //         address targetContract,
// //         bytes4 targetSelector,
// //         bytes memory targetCallArgs
// //     )
// //         public
// //         view
// //         returns(bytes32)
// //     {
// //         address decoder = _callArgsDecoderByTarget[bytes24(abi.encodePacked(targetContract, targetSelector))];
// //         if (decoder == address(0)) {
// //             return keccak256(
// //                 abi.encodePacked(
// //                     targetContract,
// //                     abi.encodeWithSelector(targetSelector, targetCallArgs)
// //                 )
// //             );
// //         }
// //         uint128 scenario, uint128 weigh IInteractionCallArgsDecoder(decoder).decodeCallArgs(targetCallArgs)

// //     }

// //     function setupInteraction(
// //         uint128 assignedWeight,
// //         uint128 coolDownDuration,
// //         uint128 invocationsCountAnnualThreshold,
// //         uint128 processingEnabledAt,
// //         address targetContract,
// //         bytes4 targetSelector,
// //         bytes memory targetCallArgs
// //     )
// //         external
// //     {
// //         // authorized
// //         TInteractionSetupData memory setupData;
// //         setupData.assignedWeight = assignedWeight;
// //         setupData.cooldownDuration = coolDownDuration;
// //         setupData.invocationsCountAnnualThreshold = invocationsCountAnnualThreshold;
// //         setupData.processingEnabledAt = processingEnabledAt == 0 ? uint128(block.timestamp) : processingEnabledAt;
// //         bytes32 interactionHash = _calcInteractionHash(targetContract, targetSelector, targetCallArgs);
// //         _setupDataByHash[interactionHash] = setupData;
// //     }

// //     function processInteractionsBulk(
// //         address[] calldata interactionSenders,

// //     ) external {

// //     }

// //     function processInteraction(
// //         address interactionSender,
// //         address targetContract,
// //         bytes4 targetSelector,
// //         bytes memory targetCallArgs
// //     )
// //         public
// //     {
// //         bytes32 interactionHash = _calcInteractionHash(targetContract, targetSelector, targetCallArgs);
// //         TInteractionSetupData memory setupData = _setupDataByHash[interactionHash];
// //         TInteractionProcessData memory processData = _processDataByHash[interactionHash];
// //         if (setupData.processingEnabledAt != 0 && block.timestamp > setupData.processingEnabledAt) {
// //             uint128 invocationsCount = processData.invocationsCount + 1;
// //             uint128 countToYear = invocationsCount * _SECONDS_PER_ANNUM / (uint128(block.timestamp) - setupData.processingEnabledAt);
// //             if (countToYear > setupData.invocationsCountAnnualThreshold) {
// //                 // raise
// //                 revert();
// //             }
// //             if (processData.lastInvocationTimestamp != 0 && uint128(block.timestamp) - processData.lastInvocationTimestamp < setupData.cooldownDuration) {
// //                 // raise
// //                 revert();
// //             }
// //             TInteractionProcessData storage ref = _processDataByHash[interactionHash];
// //             ref.invocationsCount++;
// //             ref.lastInvocationTimestamp = uint128(block.timestamp);
// //             _pendingScoreBySender[interactionSender] += setupData.assignedWeight;
// //         }
// //     }
// // }
