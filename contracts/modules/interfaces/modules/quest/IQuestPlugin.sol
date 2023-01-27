//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../IPlugin.sol";

/// @title RewardingModule
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
interface IQuestPlugin is IPlugin {
    event QuestDeactivated(uint256 questId);
    event QuestActivated(uint256 questId);
    event QuestCreated(uint256 questId);
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
        uint256 start;
        uint256 tasksCount;
    }

    function create(
        uint256 _role,
        string memory _uri,
        uint256 _durationInDays
    ) external returns (uint256);

    function getById(uint256 questId) external view returns (QuestModel memory);

    function hasCompletedAQuest(address user, uint256 questId)
        external
        view
        returns (bool);

    function addTasks(uint256 questId, PluginTasks[] calldata tasks) external;

    function removeTasks(uint256 questId, PluginTasks[] calldata tasksToRemove)
        external;

    function isActive(uint256 questId) external view returns (bool);

    function hasCompletedQuestForRole(address user, uint256 role)
        external
        view
        returns (bool);
}
