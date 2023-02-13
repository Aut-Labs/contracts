//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../IModule.sol";

/// @title RewardingModule
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
interface QuestsModule is IModule {
    event QuestCreated(uint256 questId);
    event QuestEditted();
    event TasksAddedToQuest();
    event TasksRemovedFromQuest();

    struct PluginTasks {
        uint256 pluginId;
        uint256 taskId;
    }

    struct QuestModel {
        uint256 role;
        bool active;
        string metadataUri;
        uint256 durationInDays;
        uint256 startDate;
        uint256 tasksCount;
    }
    /// @notice Creates a new quest
    /// @param role The role of the quest
    /// @param uri IPFS CID with the off-chain data of the quest
    /// @param durationInDays Duration of the quest
    /// @return The id of the newly created quest.
    function create(
        uint256 role,
        string memory uri,
        uint256 durationInDays
    ) external returns (uint256);

    /// @notice Edits a Quest
    /// @param questId The id of the quest to edit
    /// @param role The role of the quest
    /// @param uri IPFS CID with the off-chain data of the quest
    /// @param durationInDays Duration of the quest
    function editQuest(
        uint256 questId,
        uint256 role,
        string memory uri,
        uint256 durationInDays
    ) external;

    /// @notice Fetches quest by ID
    /// @param questId the id of the quest
    /// @return the QuestModel structure.
    function getById(uint256 questId) external view returns (QuestModel memory);

    /// @notice Checks if a specific user has completed a quest by ID
    /// @param user the address of the user
    /// @param questId the id of the quest
    /// @return bool
    function hasCompletedAQuest(address user, uint256 questId)
        external
        view
        returns (bool);

    /// @notice Adds tasks to the quest
    /// @param questId The id of the quest
    /// @param tasks The tasks to add 
    function addTasks(uint256 questId, PluginTasks[] calldata tasks) external;

    /// @notice Removes tasks to the quest
    /// @param questId The id of the quest
    /// @param tasksToRemove The tasks to add 
    function removeTasks(uint256 questId, PluginTasks[] calldata tasksToRemove)
        external;


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
    function hasCompletedQuestForRole(address user, uint256 role)
        external
        view
        returns (bool);

    function getTimeOfCompletion(address user, uint256 questId)
        external
        view
        returns (uint256);
}
