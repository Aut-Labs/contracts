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
        // require(IDAOAdmin(_dao).isAdmin(msg.sender), "not an admin");
        // require(questsPlugin.roleToQuestID(1), "No quest added for role 1");
        // require(questsPlugin.roleToQuestID(2), "No quest added for role 2");
        // require(questsPlugin.roleToQuestID(3), "No quest added for role 3");
        // _setActive(active);
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