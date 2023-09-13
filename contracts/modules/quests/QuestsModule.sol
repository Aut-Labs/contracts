//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../IModule.sol";

/// @title RewardingModule
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
interface QuestsModule is IModule {
    event QuestCreated(uint256 questId);
    event QuestEdited();
    event TasksAddedToQuest(uint256 questId, uint256 taskId);
    event TasksRemovedFromQuest();
    event QuestCompleted(uint256 questId, address user);
    event Applied(uint256 questId, address user);
    event Withdrawn(uint256 questId, address user);

    struct PluginTasks {
        uint256 pluginId;
        uint256 taskId;
    }

    struct QuestModel {
        uint256 role;
        bool active;
        string metadataUri;
        uint256 durationInHours;
        uint256 startDate;
        uint256 tasksCount;
    }

    /// @notice Creates a new quest
    /// @param role The role of the quest
    /// @param uri IPFS CID with the off-chain data of the quest
    /// @param startDate startDate of the quest
    /// @param durationInHours Duration of the quest
    /// @return The id of the newly created quest.
    function create(uint256 role, string memory uri, uint256 startDate, uint256 durationInHours)
        external
        returns (uint256);

    /// @notice Edits a Quest
    /// @param questId The id of the quest to edit
    /// @param role The role of the quest
    /// @param uri IPFS CID with the off-chain data of the quest
    /// @param durationInHours Duration of the quest
    function editQuest(uint256 questId, uint256 role, string memory uri, uint256 durationInHours) external;

    /// @notice Fetches quest by ID
    /// @param questId the id of the quest
    /// @return the QuestModel structure.
    function getById(uint256 questId) external view returns (QuestModel memory);

    /// @notice Checks if a specific user has completed a quest by ID
    /// @param user the address of the user
    /// @param questId the id of the quest
    /// @return bool
    function hasCompletedAQuest(address user, uint256 questId) external view returns (bool);

    /// @notice Creates a task in relation to a quest
    /// @param questId The id of the quest
    /// @param tasksPluginId The tasks to add
    /// @param uri metadata of the task
    function createTask(uint256 questId, uint256 tasksPluginId, string memory uri) external;

    /// @notice Removes tasks to the quest
    /// @param questId The id of the quest
    /// @param tasksToRemove The tasks to add
    function removeTasks(uint256 questId, PluginTasks[] calldata tasksToRemove) external;

    /// @notice Checks if a quest is ongoing
    /// @param questId The id of the quest
    /// @return bool.
    function isOngoing(uint256 questId) external view returns (bool);

    /// @notice Checks if a quest is pending
    /// @param questId The id of the quest
    /// @return bool.
    function isPending(uint256 questId) external view returns (bool);

    /// @notice Checks if a user has completed a quest. This one is used for onboarding, when the user doesn't yet have a role
    /// @param user the address of the user
    /// @param role The role of the user
    /// @return bool.
    function hasCompletedQuestForRole(address user, uint256 role) external view returns (bool);

    /// @notice gets timestamp of completion of the quest, if quest not completed - it returns 0
    /// @param user the address of the user
    /// @param questId The id of the quest
    /// @return uint256.
    function getTimeOfCompletion(address user, uint256 questId) external view returns (uint256);

    /// @notice gets total amount of quests
    /// @return uint256.
    function getTotalQuests() external view returns (uint256);

    /// @notice sets the active quest per role
    /// @param role the id of the role
    /// @param questId The id of the quest
    function setActiveQuestPerRole(uint256 role, uint256 questId) external;
}
