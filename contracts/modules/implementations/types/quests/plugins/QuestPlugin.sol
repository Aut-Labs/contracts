//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../../../../daoUtils/interfaces/get/IDAOInteractions.sol";
import "../../../../../daoUtils/interfaces/get/IDAOAdmin.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../../../../interfaces/modules/quest/QuestsModule.sol";
import "../../SimplePlugin.sol";
import "../../../../interfaces/modules/tasks/TasksModule.sol";
import "../../../../interfaces/registry/IPluginRegistry.sol";

contract QuestPlugin is QuestsModule, SimplePlugin {
    using Counters for Counters.Counter;

    Counters.Counter private idCounter;

    QuestModel[] quests;
    address public onboardingPlugin;
    uint256 public maxAmountOfCompletions;

    uint256 constant SECONDS_IN_DAY = 86400;
    mapping(uint256 => PluginTasks[]) questTasks;
    mapping(uint256 => uint256) public roleToQuestID;

    constructor(address dao) SimplePlugin(dao) {
        idCounter.increment();
        onboardingPlugin = msg.sender;
        quests.push(QuestModel(0, false, "", 0, block.timestamp, 0));
    }

    modifier onlyAdmin() {
        require(IDAOAdmin(daoAddress()).isAdmin(msg.sender), "Not an admin.");
        _;
    }

    function create(
        uint256 _role,
        string memory _uri,
        uint256 _durationInDays
    ) public onlyAdmin override returns (uint256) {
        require(bytes(_uri).length > 0, "No URI");
        uint256 questId = idCounter.current();

        quests.push(
            QuestModel(_role, false, _uri, _durationInDays, block.timestamp, 0)
        );

        roleToQuestID[_role] = questId;

        idCounter.increment();
        emit QuestCreated(questId);
        return questId;
    }

    function createTask(
        uint256 questId,
        uint256 tasksPluginId,
        string memory uri
    ) public onlyAdmin {
        IPluginRegistry.PluginInstance memory pluginInstance = pluginRegistry
            .getPluginInstanceByTokenId(tasksPluginId);
        uint256 taskId = TasksModule(pluginInstance.pluginAddress).createBy(
            msg.sender,
            quests[questId].role,
            uri
        );
        _addTask(questId, PluginTasks(tasksPluginId, taskId));
        emit TasksAddedToQuest();
    }

    function addTasks(uint256 questId, PluginTasks[] calldata tasks)
        public
        onlyAdmin
        override
    {
        require(idCounter.current() >= questId, "invalid quest id");
        for (uint256 i = 0; i < tasks.length; i++) {
           _addTask(questId, tasks[i]);
        }

        emit TasksAddedToQuest();
    }

    function removeTasks(uint256 questId, PluginTasks[] calldata tasksToRemove)
        public
        onlyAdmin
        override
    {
        require(idCounter.current() >= questId, "invalid quest id");

        for (uint256 i = 0; i < tasksToRemove.length; i++) {
            _removeTask(questId, tasksToRemove[i]);
        }

        emit TasksRemovedFromQuest();
    }

    function isQuestActive(uint256 questId)
        public
        view
        override
        returns (bool)
    {
        return
            quests[questId].start +
                quests[questId].durationInDays *
                SECONDS_IN_DAY <
            block.timestamp;
    }

    function setActive(bool active) onlyAdmin public {
        _setActive(active);
    }

    function getById(uint256 questId)
        public
        view
        override
        returns (QuestModel memory)
    {
        return quests[questId];
    }

    function getTasksPerQuest(uint256 questId)
        public
        view
        returns (PluginTasks[] memory)
    {
        return questTasks[questId];
    }

    function hasCompletedAQuest(address user, uint256 questId)
        public
        view
        override
        returns (bool)
    {
        if (questTasks[questId].length == 0) return false;
        for (uint256 i = 0; i < questTasks[questId].length; i++) {
            address tasksAddress = IPluginRegistry(pluginRegistry)
                .getPluginInstanceByTokenId(questTasks[questId][i].pluginId)
                .pluginAddress;
            if (
                !TasksModule(tasksAddress).hasCompletedTheTask(
                    user,
                    questTasks[questId][i].taskId
                )
            ) return false;
        }
        return true;
    }

    function hasCompletedQuestForRole(address user, uint256 role)
        public
        view
        override
        returns (bool)
    {
        uint256 questId = roleToQuestID[role];
        if (questId == 0) return false;
        return hasCompletedAQuest(user, questId);
    }

    // private

    function findTask(uint256 questId, PluginTasks memory task)
        private
        view
        returns (int256)
    {
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
        IPluginRegistry.PluginInstance memory plugin = IPluginRegistry(
            pluginRegistry
        ).getPluginInstanceByTokenId(task.pluginId);

        require(plugin.pluginAddress != address(0), "Invalid plugin");
        bool isInstalled = IPluginRegistry(pluginRegistry)
            .pluginDefinitionsInstalledByDAO(
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
            }
        }

        emit TasksAddedToQuest();
    }

    function _removeTask(uint256 questId, PluginTasks calldata taskToRemove)
        public
    {
        require(idCounter.current() >= questId, "invalid quest id");

            int256 index = findTask(questId, taskToRemove);

            if (index != -1) {
                questTasks[questId][uint256(index)].taskId = 0;
                questTasks[questId][uint256(index)].pluginId = 0;
                quests[questId].tasksCount--;
            }

        emit TasksRemovedFromQuest();
    }
}
