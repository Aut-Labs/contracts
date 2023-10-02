//SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.19;

import {SimplePlugin} from "../SimplePlugin.sol";
import {ILocalReputation} from "../../ILocalReputation.sol";
import {INova} from "../../nova/interfaces/INova.sol";
import {InteractionModifier} from "./InteractionModifier.sol";

import {IPluginRegistry} from "../registry/IPluginRegistry.sol";

import "forge-std/console.sol";

contract SocialBotPlugin is SimplePlugin, InteractionModifier {
    uint256 public indexAtPeriod;

    constructor(address nova_) SimplePlugin(nova_, 0) InteractionModifier(nova_) {
        ILR = ILocalReputation(IPluginRegistry(INova(nova_).pluginRegistry()).defaultLRAddr());
        ILR.initialize(nova_);
    }

    struct SocialBotEvent {
        address[] participants;
        uint16[] distributedPoints;
        string categoryOrDescription;
        uint256 when;
        uint16 maxPointsPerUser;
    }
    /// add to available interaction as relevant to performance metric ammended via setWeights

    SocialBotEvent[] allBotInteractions;

    error LenMismatch();
    error Unauthorised();
    error NotBot();
    error OverMaxPoints();
    error NotAdmin();

    event SocialEventRegistered(uint256 EventIndex);

    function applyEventConsequences(
        address[] memory participants,
        uint16[] memory participationPoints,
        uint16 maxPossiblePointsPerUser,
        string memory categoryOrDescription
    ) external returns (uint256 indexId) {
        if (!INova(novaAddress()).isAdmin(msg.sender)) revert NotAdmin();
        if (participants.length != participationPoints.length) revert LenMismatch();

        for (indexId; indexId < participants.length;) {
            if (participationPoints[indexId] > 1_000) revert OverMaxPoints();
            ILR.interaction(abi.encodePacked(participationPoints[indexId]), participants[indexId]);
            unchecked {
                ++indexId;
            }
        }

        SocialBotEvent memory SBE;
        SBE.participants = participants;
        SBE.distributedPoints = participationPoints;
        SBE.categoryOrDescription = categoryOrDescription;
        SBE.when = block.timestamp;
        SBE.maxPointsPerUser = maxPossiblePointsPerUser;

        indexId = participants.length;
        allBotInteractions.push(SBE);
        uint16[] memory points = new uint16[](1);
        bytes[] memory datas = new bytes[](1);
        datas[0] = abi.encode(indexId, address(this));
        points[0] = maxPossiblePointsPerUser;

        ILR.setInteractionWeights(address(this), datas, points);

        emit SocialEventRegistered(indexId);
    }

    function getAllBotInteractions() public view returns (SocialBotEvent[] memory) {
        return allBotInteractions;
    }
}
