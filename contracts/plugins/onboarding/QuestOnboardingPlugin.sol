// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "../../modules/onboarding/OnboardingModule.sol";
import "../quests/QuestPlugin.sol";
import "../SimplePlugin.sol";
import "../../daoUtils/interfaces/get/IDAOAdmin.sol";

import {QuestsModule} from "../../modules/quests/QuestsModule.sol";

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
     * @dev quest plugin struct  - id association  is role dependent. todo: refactor. reduce contract deployment and consolidate storage. collapse current.
     */
    function setActive(bool active) public onlyAdmin {
        uint256 pluginId = pluginRegistry.tokenIdFromAddress(address(this));

        QuestsModule.QuestModel memory Q = questsPlugin.getById(pluginId);
        if (Q.startDate > block.timestamp) revert("AlreadyStarted");
        if (Q.startDate + (Q.durationInHours * 1 hours) > block.timestamp) revert("Ended");
        if (Q.tasksCount == 0) revert("NoTasks");

        _setActive(active);
    }
    /**
     * @dev Checks whether a member has been onboarded.
     * @param member The member address.
     * @param role The member's role.
     * @return A boolean indicating whether the member has been onboarded.
     */

    function isOnboarded(address member, uint256 role) public view override returns (bool) {
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
        revert("FunctionNotImplemented");
    }
}
