//SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.19;

import {OpenTaskPlugin} from "../tasks/OpenTaskPlugin.sol";
import {InteractionModifier} from "./InteractionModifier.sol";
import {ILocalReputation} from "../../ILocalReputation.sol";

import {IPluginRegistry} from "../registry/IPluginRegistry.sol";

import {INova} from "../../nova/interfaces/INova.sol";

contract OffchainTaskWithRep is OpenTaskPlugin, InteractionModifier {
    constructor(address nova_) OpenTaskPlugin(nova_, true) InteractionModifier(nova_) {
        ILR = ILocalReputation(IPluginRegistry(INova(nova_).pluginRegistry()).defaultLRAddr());
        ILR.initialize(nova_);
    }

    function finalizeFor(uint256 taskId, address submitter)
        public
        override
        isAsInteraction(abi.encodeWithSelector(msg.sig, taskId), submitter)
        atStatus(taskId, submitter, TaskStatus.Submitted)
        onlyCreator(taskId)
    {
        super.finalizeFor(taskId, submitter);
    }

    /// @notice the creator of the task can use to set number of points to be awared for finalizing a task
    /// @param taskID ID of task to assign points balance to
    /// @param pointsWeight how many points the task will be worth
    function setWeightForTask(uint256 taskID, uint16 pointsWeight) external onlyCreator(taskID) {
        bytes memory dataTaskCall = abi.encodeWithSelector(this.finalizeFor.selector, taskID);
        bytes[] memory bts = new bytes[](1);
        uint16[] memory pts = new uint16[](1);
        bts[0] = dataTaskCall;
        pts[0] = pointsWeight;

        ILR.setInteractionWeights(address(this), bts, pts);
    }
}
