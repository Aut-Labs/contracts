//SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.19;

import {OpenTaskPlugin} from "../tasks/OpenTaskPlugin.sol";
import {InteractionModifier} from "./InteractionModifier.sol";
import {ILocalReputation} from "./ILocalReputation.sol";

contract OpenTaskWithRep is OpenTaskPlugin, InteractionModifier {
    constructor(address nova_) OpenTaskPlugin(nova_, true) InteractionModifier(nova_) {}

    function submit(uint256 taskId, string calldata submitionUrl)
        public
        override
        onlyAllowedToSubmit
        isInteraction
        atStatus(taskId, msg.sender, TaskStatus.Created)
    {
        super.submit(taskId, submitionUrl);
    }
}
