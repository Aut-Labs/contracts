pragma solidity ^0.8.0;

import "../../../../interfaces/modules/onboarding/OnboardingModule.sol";
import "../../../../implementations/types/quests/plugins/QuestPlugin.sol";
import "../../SimplePlugin.sol";

contract QuestOnboardingPlugin is SimplePlugin, OnboardingModule {

    QuestPlugin public questsPlugin;

    constructor(address dao) SimplePlugin(dao) {
        questsPlugin = new QuestPlugin(dao);
    }

    // Implements the onboard function from the OnboardingModule interface
    function isOnboarded(address member, uint role) public override view returns (bool) {
        return questsPlugin.hasCompletedQuestForRole(member, role);
    }

    // Implements the onboard function from the OnboardingModule interface
    function onboard(address member, uint role) public override {
        revert FunctionNotImplemented();
    }

    function getQuestsPluginAddress() public view returns(address) {
        return address(questsPlugin);
    }
}
