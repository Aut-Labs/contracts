//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../IModule.sol";
import "./TasksModule.sol";
/* 
The tasks module implements a simple State Machine for on chain tasks. 
The state machine has 4 states - Created, Taken, Submitted, Finalized. 
The task itself is associated with а role.
The off-chain data of the task such as description, title, tags etc is represented by IPFS CID pointing to a JSON file. 
Every tasks plugin must implement this interface.
*/
/// @title TasksModule - interaface
/// @notice Every tasks plugin must implement this interface
interface QuestTasksModule is TasksModule {

    event TaskAddedToAQuest(uint taskId, uint questId);

    event TaskRemovedFromAQuest(uint taskId, uint questId);
    
    function addTaskToAQuest(uint taskId, uint questId) external;

    function removeTaskFromAQuest(uint taskId, uint questId) external;

    function getTasksByQuestID(uint questId) view external returns(uint[] memory);

    function setQuestsAddress(address questsAddress) external;
}
