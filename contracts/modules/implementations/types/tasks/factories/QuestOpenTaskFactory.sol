//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IQuestOpenTaskFactory.sol";
import "../plugins/questTasks/OnboardingOpenTaskPlugin.sol";

contract QuestOpenTaskFactory is IQuestOpenTaskFactory {

    function deployOpenTaskPlugin(address dao, address questsAddress)
        public
        override
        returns (address _pluginAddress)
    {
        OnboardingQuestOpenTaskPlugin plugin = new OnboardingQuestOpenTaskPlugin(
                dao,
                questsAddress
            );
        return address(plugin);
    }
}
