//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../IModule.sol";
/* 
The tasks module implements a simple State Machine for on chain tasks. 
The state machine has 4 states - Created, Taken, Submitted, Finalized. 
The task itself is associated with а role.
The off-chain data of the task such as description, title, tags etc is represented by IPFS CID pointing to a JSON file. 
Every tasks plugin must implement this interface.
*/
/// @title TasksModule - interaface
/// @notice Every tasks plugin must implement this interface
interface TasksModule is IModule {

    // reverted when the current state of a task is invalid for executing an action
    error FunctionInvalidAtThisStage();
    // emitted when task is created
    event TaskCreated(uint256 taskID, string uri);
    // emitted when task is taken
    event TaskTaken(uint256 taskID, address taker);
    // emitted when a task is submitted
    event TaskSubmitted(uint256 taskID);
    // emitted when a task is finalized
    event TaskFinalized(uint256 taskID, address taker);

    // The states that a task can have
    enum TaskStatus {
        Created,
        Taken,
        Submitted,
        Finished
    }

    // struct representing a Task 
    // createdOn - timestamp 
    // status - on of the TaskStatus
    // creator - address of the creator
    // taker - address of the taker
    // submitionUrl - IPFS CID with JSON file with the submition data
    // role - the role of the task, if 0 - it means it is for all roles
    // metadata - IPFS CID with JSON file with the task data
    struct Task {
        uint256 createdOn;
        TaskStatus status;
        address creator;
        address taker;
        string submitionUrl;
        uint256 role;
        string metadata;
        uint startDate;
        uint endDate;
    }

    
    /// @notice Creates a new task
    /// @param role The role with which the task is associated
    /// @param uri IPFS CID with the off-chain data of the task
    /// @return The id of the newly created task.
    function create(uint256 role, string memory uri, uint startDate, uint endDate) external returns (uint256);

    /// @notice Creates a new task
    /// @param creator The creator of the task
    /// @param role The role with which the task is associated
    /// @param uri IPFS CID with the off-chain data of the task
    /// @return The id of the newly created task.
    function createBy(address creator, uint256 role, string memory uri, uint startDate, uint endDate) external returns (uint256); 
    
    /// @notice A function for taking a task. The signer is the taker.
    /// @param taskID the id of the task
    function take(uint256 taskID) external;

    /// @notice A function for submitting a task. Conceptually only the taker can submit it.
    /// @param taskID the id of the task
    /// @param submitionUrl IPFS CID with the off-chain submission data.
    function submit(uint256 taskID, string calldata submitionUrl) external;

    /// @notice A function for finalizing a task. 
    /// @param taskID the task ID 
    function finalize(uint256 taskID) external;

    /// @notice A function for finalizing a task for a specific member. 
    /// @param taskID the task ID 
    /// @param submitter the address of the submitter 
    function finalizeFor(uint256 taskID, address submitter) external;

    /// @notice Fetches task by ID
    /// @param taskID the id of the task
    /// @return the Task structure.
    function getById(uint256 taskID) external view returns (Task memory);


    /// @notice Checks if a specific user has completed a task by ID
    /// @param user the address of the user
    /// @param taskID the id of the task
    /// @return bool
    function hasCompletedTheTask(address user, uint taskID) external view returns(bool);
}
