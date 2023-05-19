// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../modules/onboarding/OnboardingModule.sol";
import "../quests/QuestPlugin.sol";
import "../SimplePlugin.sol";
import "../../daoUtils/interfaces/get/IDAOAdmin.sol";

/**
 * @title QuestOnboardingPlugin
 * @dev A plugin contract that implements the `OnboardingModule` interface and uses a `QuestPlugin` to onboard members via quests.
 */
contract QuestOnboardingPlugin is SimplePlugin, OnboardingModule {
    QuestPlugin public questsPlugin;

    /**
     * @dev Initializes a new `QuestOnboardingPlugin` instance.
     * @param dao The DAO address.
     */
    constructor(address dao) SimplePlugin(dao, 1) {
        questsPlugin = new QuestPlugin(dao);
        _setActive(false);
    }

    modifier onlyAdmin() {
        require(IDAOAdmin(daoAddress()).isAdmin(msg.sender), "Not an admin.");
        _;
    }

    /**
     * @dev Sets the active status of the plugin.
     * @param active A boolean indicating whether the plugin should be set as active.
     */
    function setActive(bool active) public onlyAdmin {
        uint activeQuestRole1 = questsPlugin.activeQuestsPerRole(1);
        uint activeQuestRole2 = questsPlugin.activeQuestsPerRole(2);
        uint activeQuestRole3 = questsPlugin.activeQuestsPerRole(3);
        if (active) {
            require(
                activeQuestRole1 > 0 &&
                    activeQuestRole2 > 0 &&
                    activeQuestRole3 > 0,
                "not all quests are defined"
            );
            require(
                questsPlugin.getById(activeQuestRole1).tasksCount > 0 &&
                    questsPlugin.getById(activeQuestRole2).tasksCount > 0 &&
                    questsPlugin.getById(activeQuestRole3).tasksCount > 0,
                "not all quests have tasks"
            );
        } else {
            require(
                questsPlugin.getById(activeQuestRole1).startDate == 0 ||
                    questsPlugin.getById(activeQuestRole1).startDate >
                    block.timestamp,
                "quest started"
            );
            require(
                questsPlugin.getById(activeQuestRole2).startDate == 0 ||
                    questsPlugin.getById(activeQuestRole2).startDate >
                    block.timestamp,
                "quest started"
            );
            require(
                questsPlugin.getById(activeQuestRole3).startDate == 0 ||
                    questsPlugin.getById(activeQuestRole3).startDate >
                    block.timestamp,
                "quest started"
            );
        }

        _setActive(active);
    }

    /**
     * @dev Checks whether a member has been onboarded.
     * @param member The member address.
     * @param role The member's role.
     * @return A boolean indicating whether the member has been onboarded.
     */
    function isOnboarded(
        address member,
        uint256 role
    ) public view override returns (bool) {
        return questsPlugin.hasCompletedQuestForRole(member, role);
    }

    /**
     * @dev Gets the address of the `QuestPlugin` contract.
     * @return The address of the `QuestPlugin` contract.
     */
    function getQuestsPluginAddress() public view returns (address) {
        return address(questsPlugin);
    }

    /**
     * @dev Onboards a member.
     * @param member The member address.
     * @param role The member's role.
     */
    function onboard(address member, uint256 role) public override {
        revert FunctionNotImplemented();
    }
}
