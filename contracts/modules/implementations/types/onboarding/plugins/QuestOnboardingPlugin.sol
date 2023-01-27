pragma solidity ^0.8.0;

import "../../../../interfaces/modules/onboarding/IOnboardingPlugin.sol";
import "../../../../interfaces/modules/quest/IQuestPlugin.sol";
import "../../../../implementations/types/quests/plugins/QuestPlugin.sol";
import "../../SimplePlugin.sol";

contract QuestOnboardingPlugin is SimplePlugin, IOnboardingPlugin {

    IQuestPlugin public questsPlugin;

    constructor(address dao) SimplePlugin(dao) {
        questsPlugin = new QuestPlugin(dao);
    }

    // Implements the onboard function from the IOnboardingPlugin interface
    function isOnboarded(address member, uint role) public override view returns (bool) {
        return questsPlugin.hasCompletedQuestForRole(member, role);
    }

    // Implements the onboard function from the IOnboardingPlugin interface
    function onboard(address member, uint role) public override {
        revert FunctionNotImplemented();
    }

    function getQuestsPluginAddress() public view returns(address) {
        return address(questsPlugin);
    }
}
