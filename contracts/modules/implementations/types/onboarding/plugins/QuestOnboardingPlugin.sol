pragma solidity ^0.8.0;

import "../../../../interfaces/modules/onboarding/OnboardingModule.sol";
import "../../../../implementations/types/quests/plugins/QuestPlugin.sol";
import "../../SimplePlugin.sol";
import "../CooldownOnboardingPeriod.sol";
import "../../../../../daoUtils/interfaces/get/IDAOAdmin.sol";

contract QuestOnboardingPlugin is SimplePlugin, CooldownOnboardingPeriod, OnboardingModule {
    uint256 constant SECONDS_IN_DAY = 86400;
    QuestPlugin public questsPlugin;

    constructor(address dao) SimplePlugin(dao) {
        questsPlugin = new QuestPlugin(dao);
        _setActive(false);
    }
    
    function setCooldownPeriod(uint amountOfDays) public {
        require(IDAOAdmin(_dao).isAdmin(msg.sender), "not an admin");
        _setCooldownPeriod(amountOfDays * SECONDS_IN_DAY);
    }

    function setActive(bool active) public {
        require(IDAOAdmin(_dao).isAdmin(msg.sender), "not an admin");
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

    function isCooldownPassed(address user, uint256 role) public override view returns (bool) {
        require(isOnboarded(user, role), "User not onboarded");
        uint completionTime = questsPlugin.getTimeOfCompletion(user, role);
        return completionTime + getCooldownPeriod() <= block.timestamp;
    }

    // Implements the onboard function from the OnboardingModule interface
    function onboard(address member, uint256 role) public override {
        revert FunctionNotImplemented();
    }
}