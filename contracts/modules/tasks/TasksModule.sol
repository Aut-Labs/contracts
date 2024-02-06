//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../IModule.sol";

/**
 * @title TasksModule
 * @notice Implements a simple State Machine for on-chain tasks.
 * The state machine has 4 states - Created, Taken, Submitted, Finalized.
 * The task itself is associated with а role.
 * The off-chain data of the task such as description, title, tags etc is represented by IPFS CID pointing to a JSON file.
 * Every tasks plugin must implement this interface.
 */
interface TasksModule is IModule {
    /**
     * @notice Reverted when the current state of a task is invalid for executing an action
     */
    error FunctionInvalidAtThisStage();

    /**
     * @notice Emitted when a task is created
     * @param taskID The id of the newly created task
     * @param uri IPFS CID with the off-chain data of the task
     */
    event TaskCreated(uint256 taskID, string uri);

    /**
     * @notice Emitted when a task is edited
     * @param taskID The id of the newly created task
     * @param uri IPFS CID with the off-chain data of the task
     */
    event TaskEdited(uint256 taskID, string uri);

    /**
     * @notice Emitted when a task is taken
     * @param taskID The id of the task
     * @param taker The address of the taker
     */
    event TaskTaken(uint256 taskID, address taker);

    /**
     * @notice Emitted when a task is submitted
     * @param taskID The id of the task
     * @param submissionId The id of the submission
     */
    event TaskSubmitted(uint256 taskID, uint256 submissionId);

    /**
     * @notice Emitted when a task is finalized
     * @param taskID The id of the task
     * @param taker The address of the taker
     */
    event TaskFinalized(uint256 taskID, address taker);

    /**
     * @notice The states that a task can have
     */
    enum TaskStatus {
        Created,
        Taken,
        Submitted,
        Finished
    }

    /**
     * @notice Struct representing a Task
     * @param createdOn The timestamp of when the task was created
     * @param creator The address of the creator of the task
     * @param role The role with which the task is associated
     * @param metadata IPFS CID with JSON file with the task data
     * @param startDate The start date of the task
     * @param endDate The end date of the task
     */
    struct Task {
        uint256 createdOn;
        address creator;
        uint256 role;
        string metadata;
        uint256 startDate;
        uint256 endDate;
    }

    /**
     * @notice Creates a new task
     * @param role The role with which the task is associated
     * @param uri IPFS CID with the off-chain data of the task
     * @return The id of the newly created task
     */
    function create(uint256 role, string memory uri, uint256 startDate, uint256 endDate) external returns (uint256);

    /**
     * @notice Creates a new task
     * @param creator The creator of the task
     * @param role The role with which the task is associated
     * @param uri IPFS CID with the off-chain data of the task
     * @return The id of the newly created task
     */
    function createBy(
        address creator,
        uint256 role,
        string memory uri,
        uint256 startDate,
        uint256 endDate
    ) external returns (uint256);

    /**
     * @notice Edits a task
     * @param taskId The id of the task
     * @param role The role with which the task is associated
     * @param uri IPFS CID with the off-chain data of the task
     * @param startDate The start date of the task
     * @param endDate The end date of the task
     */
    function editTask(uint256 taskId, uint256 role, string memory uri, uint256 startDate, uint256 endDate) external;

    /// @notice A function for taking a task. The signer is the taker.
    /// @param taskID the id of the task
    function take(uint256 taskID) external;

    /// @notice A function for submitting a task.
    /// Conceptually only the taker can submit it.
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
    function hasCompletedTheTask(address user, uint256 taskID) external view returns (bool);

    /// @notice Gets the status of a task for a specific submitter.
    /// @param taskId the id of the task
    /// @param submitter the address of the submitter
    /// @return TaskStatus
    function getStatusPerSubmitter(uint256 taskId, address submitter) external view returns (TaskStatus);

    /// @notice Gets the completion time of a task for a specific user.
    /// @param taskId the id of the task
    /// @param user the address of the user
    /// @return uint
    function getCompletionTime(uint256 taskId, address user) external view returns (uint256);
}
