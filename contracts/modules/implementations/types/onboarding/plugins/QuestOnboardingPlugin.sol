pragma solidity ^0.8.0;

import "../../../../interfaces/modules/onboarding/OnboardingModule.sol";
import "../../../../implementations/types/quests/plugins/QuestPlugin.sol";
import "../../SimplePlugin.sol";
import "../../../../../daoUtils/interfaces/get/IDAOAdmin.sol";

contract QuestOnboardingPlugin is SimplePlugin, OnboardingModule {
    uint256 constant SECONDS_IN_DAY = 86400;
    QuestPlugin public questsPlugin;

    constructor(address dao) SimplePlugin(dao) {
        questsPlugin = new QuestPlugin(dao);
        _setActive(false);
    }
    
    function setActive(bool active) public {
        _setActive(active);
    }
    // Implements the onboard function from the OnboardingModule interface
    function isOnboarded(address member, uint256 role)
        public
        view
        override
        returns (bool)
    {
        return questsPlugin.hasCompletedQuestForRole(member, role);
    }

    function getQuestsPluginAddress() public view returns (address) {
        return address(questsPlugin);
    }

    // Implements the onboard function from the OnboardingModule interface
    function onboard(address member, uint256 role) public override {
        revert FunctionNotImplemented();
    }
}