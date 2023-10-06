//SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.19;

import {OpenTaskPlugin} from "../tasks/OpenTaskPlugin.sol";
import {InteractionModifier} from "./InteractionModifier.sol";
import {ILocalReputation} from "../../ILocalReputation.sol";

import {IPluginRegistry} from "../registry/IPluginRegistry.sol";

import {INova} from "../../nova/interfaces/INova.sol";

contract OpenTaskWithRep is OpenTaskPlugin, InteractionModifier {
    constructor(address nova_) OpenTaskPlugin(nova_, true) InteractionModifier(nova_) {
        ILR = ILocalReputation(IPluginRegistry(INova(nova_).pluginRegistry()).defaultLRAddr());
        ILR.initialize(nova_);
    }

    function finalizeFor(uint256 taskId, address submitter)
        public
        override
        isAsInteraction(abi.encodePacked(msg.sig, taskId), submitter)
        atStatus(taskId, submitter, TaskStatus.Submitted)
        onlyCreator(taskId)
    {
        super.finalizeFor(taskId, submitter);
    }
}
