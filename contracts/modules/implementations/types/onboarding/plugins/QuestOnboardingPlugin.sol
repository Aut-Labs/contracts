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

    modifier onlyAdmin() {
        require(IDAOAdmin(daoAddress()).isAdmin(msg.sender), "Not an admin.");
        _;
    }

    function setActive(bool active) public onlyAdmin {
        require(
            questsPlugin.activeQuestsPerRole(1) > 0 &&
                questsPlugin.activeQuestsPerRole(2) > 0 &&
                questsPlugin.activeQuestsPerRole(3) > 0,
            "not all quests are defined"
        );
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
