//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";

import "../../daoUtils/interfaces/get/IDAOAdmin.sol";
import "../../daoUtils/interfaces/get/IDAOInteractions.sol";

import "../../modules/tasks/TasksModule.sol";
import "../../modules/quests/QuestsModule.sol";
import "../../modules/onboarding/OnboardingModule.sol";

import "../SimplePlugin.sol";
import "../registry/IPluginRegistry.sol";

contract QuestPlugin is QuestsModule, SimplePlugin {
    using Counters for Counters.Counter;

    Counters.Counter private idCounter;

    QuestModel[] quests;
    address public onboardingPlugin;

    uint256 constant SECONDS_IN_HOUR = 3600;
    mapping(uint256 => PluginTasks[]) questTasks;
    mapping(uint256 => uint256[]) public taskToQuests;
    mapping(uint256 => uint256) public activeQuestsPerRole;

    mapping(uint256 => mapping(address => bool)) hasApplied;
    mapping(uint256 => uint256) completionsPerQuest;

    constructor(address dao) SimplePlugin(dao, 0) {
        idCounter.increment();
        onboardingPlugin = msg.sender;
        quests.push(QuestModel(0, false, "", 0, block.timestamp, 0));
    }

    modifier onlyAdmin() {
        require(IDAOAdmin(daoAddress()).isAdmin(msg.sender), "Not an admin.");
        _;
    }

    modifier onlyOngoing(uint256 questId) {
        require(isOngoing(questId), "Only ongoing");
        _;
    }

    modifier onlyPending(uint256 questId) {
        require(isPending(questId), "Only pending");
        _;
    }

    modifier onlyActive(uint256 questId) {
        require(
            OnboardingModule(onboardingPlugin).isActive() &&
                activeQuestsPerRole[quests[questId].role] == questId,
            "Only active quest"
        );
        _;
    }

    modifier onlyApplied(uint256 questId, address user) {
        require(hasApplied[questId][user], "Only applied");
        _;
    }

    function applyForAQuest(uint256 questId) public onlyActive(questId) {
        require(isOngoing(questId) || isPending(questId), "expired quest");
        hasApplied[questId][msg.sender] = true;
        emit Applied(questId, msg.sender);
    }

    function withdrawFromAQuest(uint256 questId) public onlyActive(questId) {
        hasApplied[questId][msg.sender] = false;
        emit Withdrawn(questId, msg.sender);
    }

    function create(
        uint256 _role,
        string memory _uri,
        uint256 _startDate,
        uint256 _durationInHours
    ) public override onlyAdmin returns (uint256) {
        require(bytes(_uri).length > 0, "invalid uri");
        require(_startDate > block.timestamp, "invalid startDate");
        uint256 questId = idCounter.current();

        quests.push(
            QuestModel(_role, false, _uri, _durationInHours, _startDate, 0)
        );

        if (activeQuestsPerRole[_role] == 0)
            activeQuestsPerRole[_role] = questId;

        idCounter.increment();
        emit QuestCreated(questId);
        return questId;
    }

    function createTask(
        uint256 questId,
        uint256 tasksPluginId,
        string memory uri
    ) public override onlyAdmin onlyPending(questId) {
        IPluginRegistry.PluginInstance memory pluginInstance = pluginRegistry
            .getPluginInstanceByTokenId(tasksPluginId);
        uint256 taskId = TasksModule(pluginInstance.pluginAddress).createBy(
            msg.sender,
            quests[questId].role,
            uri,
            quests[questId].startDate,
            quests[questId].startDate +
                quests[questId].durationInHours *
                SECONDS_IN_HOUR
        );
        _addTask(questId, PluginTasks(tasksPluginId, taskId));
        emit TasksAddedToQuest(questId, taskId);
    }

    function removeTasks(
        uint256 questId,
        PluginTasks[] calldata tasksToRemove
    ) public override onlyAdmin onlyPending(questId) {
        require(idCounter.current() >= questId, "invalid quest id");

        for (uint256 i = 0; i < tasksToRemove.length; i++) {
            _removeTask(questId, tasksToRemove[i]);
        }

        emit TasksRemovedFromQuest();
    }

    function editQuest(
        uint256 questId,
        uint256 _role,
        string memory _uri,
        uint256 _durationInHours
    ) public override onlyAdmin onlyPending(questId) {
        require(idCounter.current() >= questId, "invalid quest id");
        require(_role > 0, "invalid _role");
        require(bytes(_uri).length > 0, "invalid _uri");
        require(_durationInHours > 0, "invalid _durationInHours");

        quests[questId].metadataUri = _uri;
        quests[questId].durationInHours = _durationInHours;
        quests[questId].role = _role;

        emit QuestEditted();
    }

    function isOngoing(uint256 questId) public view override returns (bool) {
        return
            quests[questId].startDate +
                quests[questId].durationInHours * 
                SECONDS_IN_HOUR <
            block.timestamp &&
            quests[questId].startDate > block.timestamp;
    }

    function isPending(uint256 questId) public view override returns (bool) {
        return quests[questId].startDate > block.timestamp;
    }

    function getById(
        uint256 questId
    ) public view override returns (QuestModel memory) {
        return quests[questId];
    }

    function getTasksPerQuest(
        uint256 questId
    ) public view returns (PluginTasks[] memory) {
        return questTasks[questId];
    }

    function hasCompletedAQuest(
        address user,
        uint256 questId
    ) public view override returns (bool) {
        return
            hasApplied[questId][user] && getTimeOfCompletion(user, questId) > 0;
    }

    function getTimeOfCompletion(
        address user,
        uint256 questId
    ) public view override returns (uint256) {
        if (questTasks[questId].length == 0) return 0;
        uint256 lastTaskTime = 0;
        for (uint256 i = 0; i < questTasks[questId].length; i++) {
            address tasksAddress = IPluginRegistry(pluginRegistry)
                .getPluginInstanceByTokenId(questTasks[questId][i].pluginId)
                .pluginAddress;
            if (
                TasksModule(tasksAddress).hasCompletedTheTask(
                    user,
                    questTasks[questId][i].taskId
                )
            ) {
                uint256 completionTime = TasksModule(tasksAddress)
                    .getCompletionTime(questTasks[questId][i].taskId, user);

                if (completionTime > lastTaskTime)
                    lastTaskTime = completionTime;
            } else {
                return 0;
            }
        }
        return lastTaskTime;
    }

    function hasCompletedQuestForRole(
        address user,
        uint256 role
    ) public view override returns (bool) {
        uint256 questId = activeQuestsPerRole[role];
        if (questId == 0) return false;
        return hasCompletedAQuest(user, questId);
    }

    function setActiveQuestPerRole(
        uint256 role,
        uint256 questId
    ) public override onlyAdmin onlyPending(questId) {
        activeQuestsPerRole[role] = questId;
    }

    function getTotalQuests() public view override returns (uint256) {
        return idCounter.current() - 1;
    }

    // private
    function findTask(
        uint256 questId,
        PluginTasks memory task
    ) private view returns (int256) {
        for (uint256 i = 0; i < questTasks[questId].length; i++) {
            if (
                questTasks[questId][i].pluginId == task.pluginId &&
                questTasks[questId][i].taskId == task.taskId
            ) {
                return int256(i);
            }
        }
        return -1;
    }

    function _addTask(uint256 questId, PluginTasks memory task) private {
        require(idCounter.current() >= questId, "invalid quest id");
        IPluginRegistry.PluginInstance memory plugin = pluginRegistry
            .getPluginInstanceByTokenId(task.pluginId);

        require(plugin.pluginAddress != address(0), "Invalid plugin");
        bool isInstalled = pluginRegistry.pluginDefinitionsInstalledByDAO(
            daoAddress(),
            plugin.pluginDefinitionId
        );
        if (
            TasksModule(plugin.pluginAddress).daoAddress() == daoAddress() &&
            isInstalled
        ) {
            int256 index = findTask(questId, task);
            if (index == -1) {
                questTasks[questId].push(task);
                quests[questId].tasksCount++;
                emit TasksAddedToQuest(questId, task.taskId);
            }
        }
    }

    function _removeTask(
        uint256 questId,
        PluginTasks calldata taskToRemove
    ) private {
        int256 index = findTask(questId, taskToRemove);
        require(index != -1, "invalid task");
        questTasks[questId][uint256(index)].taskId = 0;
        questTasks[questId][uint256(index)].pluginId = 0;
        quests[questId].tasksCount--;
    }
}
