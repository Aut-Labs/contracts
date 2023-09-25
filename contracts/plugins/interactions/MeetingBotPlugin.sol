// //SPDX-License-Identifier: UNLICENCED
// pragma solidity 0.8.19;

// import {SimplePlugin} from "../SimplePlugin.sol";
// import {InteractionModifier} from "./InteractionModifier.sol";
// import {ILocalReputation} from "./ILocalReputation.sol";

// contract DiscordBotPlugin is SimplePlugin, InteractionModifier {
//     address public botAddress;

//     constructor(address dao_, address botAddress_) SimplePlugin(dao_, 0) InteractionModifier(dao_) {
//         botAddress = botAddress_;
//     }

//     error LengthMissmatch();
//     error Unauthorised();
//     error NotBot();

//     function applyMeetingConsequences(string[] memory categories, address[] memory participants) returns (bool) {
//         if (msg.sender != botAddress) revert NotBot();
//         if (categories.length != participants.length) revert LengthMissmatch();

//     }

//     function setMeetingWeights(string[] memory categories, address[] memory users);

// }
