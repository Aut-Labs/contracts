pragma solidity ^0.8.0;

import "../../modules/onboarding/OnboardingModule.sol";
import "../quests/QuestPlugin.sol";
import "../SimplePlugin.sol";
import "../../daoUtils/interfaces/get/IDAOAdmin.sol";

contract QuestOnboardingPlugin is SimplePlugin, OnboardingModule {
    uint256 constant SECONDS_IN_DAY = 86400;
    QuestPlugin public questsPlugin;

    constructor(address dao) SimplePlugin(dao, 1) {
        questsPlugin = new QuestPlugin(dao);
        _setActive(false);
    }

    modifier onlyAdmin() {
        require(IDAOAdmin(daoAddress()).isAdmin(msg.sender), "Not an admin.");
        _;
    }

    function setActive(bool active) public onlyAdmin {
        uint activeQuestRole1 = questsPlugin.activeQuestsPerRole(1);
        uint activeQuestRole2 = questsPlugin.activeQuestsPerRole(2);
        uint activeQuestRole3 = questsPlugin.activeQuestsPerRole(3);
        require(
            activeQuestRole1 > 0 &&
                activeQuestRole2 > 0 &&
                activeQuestRole3 > 0,
            "not all quests are defined"
        );
        require(
            questsPlugin.getTasksPerQuest(activeQuestRole1).length > 0 &&
                questsPlugin.getTasksPerQuest(activeQuestRole2).length > 0 &&
                questsPlugin.getTasksPerQuest(activeQuestRole3).length > 0,
            "not all quests have tasks"
        );
        _setActive(active);
    }

    // Implements the onboard function from the OnboardingModule interface
    function isOnboarded(
        address member,
        uint256 role
    ) public view override returns (bool) {
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
