//SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.19;

import {OffchainVerifiedTaskPlugin} from "../tasks/OffchainVerifiedTaskPlugin.sol";
import {InteractionModifier} from "./InteractionModifier.sol";
import {ILocalReputation} from "../../ILocalReputation.sol";

import {IPluginRegistry} from "../registry/IPluginRegistry.sol";

import {INova} from "../../nova/interfaces/INova.sol";

contract OffchainTaskWithRep is OffchainVerifiedTaskPlugin, InteractionModifier {
    constructor(address nova_, address verifierAddr_ ) OffchainVerifiedTaskPlugin(nova_, verifierAddr_) InteractionModifier(nova_) {
        ILR = ILocalReputation(IPluginRegistry(INova(nova_).pluginRegistry()).defaultLRAddr());
    }

    function finalizeFor(uint256 taskId, address submitter)
        public
        override
        isAsInteraction(abi.encodeWithSelector(msg.sig, taskId), submitter)
        atStatus(taskId, TaskStatus.Submitted)
        onlyCreator(taskId)
    {
        super.finalizeFor(taskId, submitter);
    }

    //// @dev @todo integrate weight as part of creating the task

    /// @notice the creator of the task can use to set number of points to be awared for finalizing a task
    /// @param taskID ID of task to assign points balance to
    /// @param pointsWeight how many points the task will be worth
    function setWeightForTask(uint256 taskID, uint16 pointsWeight) public onlyCreator(taskID) {
        bytes memory dataTaskCall = abi.encodeWithSelector(this.finalizeFor.selector, taskID);
        bytes[] memory bts = new bytes[](1);
        uint16[] memory pts = new uint16[](1);
        bts[0] = dataTaskCall;
        pts[0] = pointsWeight;

        ILR.setInteractionWeights(address(this), bts, pts);
    }

    /// @notice creates task and adds associated epcoh reputation points
    /// @return taskID ID of the newly created task
    function createOffChainTaskWithWeight(
        uint256 role,
        string memory uri,
        uint256 startDate,
        uint256 endDate,
        uint16 pointsWeight
    ) external returns (uint256 taskID) {
        taskID = create(role, uri, startDate, endDate);
        setWeightForTask(taskID, pointsWeight);
    }

    /// @notice retrieves the amount of points associated with provided task id
    /// @param taskID identifier of task ID
    function getRepPointsOfTask(uint256 taskID) external view returns (uint256) {
        return uint256(
            ILR.pointsPerInteraction(
                ILR.interactionID(address(this), abi.encodeWithSelector(this.finalizeFor.selector, taskID))
            )
        );
    }
}
