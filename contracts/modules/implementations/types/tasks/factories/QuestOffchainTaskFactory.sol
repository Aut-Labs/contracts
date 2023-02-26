//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IQuestOffchainTaskFactory.sol";
import "../plugins/questTasks/OnboardingOffchainVerifiedTaskPlugin.sol";

contract QuestOffchainTaskFactory is IQuestOffchainTaskFactory {

    function deployOffchainTaskPlugin(
        address dao,
        address offchainVerifierAddress,
        address questsAddress
    ) public override returns (address _pluginAddress) {
        OnboardingQuestOffchainVerifiedTaskPlugin plugin = new OnboardingQuestOffchainVerifiedTaskPlugin(
                dao,
                offchainVerifierAddress,
                questsAddress
            );
        return address(plugin);
    }
}
