pragma solidity >=0.8.0;

struct Task {
    string uri;
    // TODO: other identifiers / metadata?
}

interface ITaskRegistry {
    error TaskAlreadyRegistered();
    error TaskNotRegistered();

    event RegisterTask(bytes32 indexed taskId, address indexed who, string uri);

    /// @notice Register an array of tasks to be used for Contributions within the TaskFactory
    function registerTasks(Task[] calldata tasks) external returns (bytes32[] memory);

    /// @notice Register a Task to be used by a Contribution within the TaskFactory
    function registerTask(Task memory task) external returns (bytes32);

    /// @notice return the Task struct given its' unique identifier
    function getTaskById(bytes32 taskId) external view returns (Task memory);

    /// @notice return the bytes of the Task given its' unique identifier
    function getTaskByIdEncoded(bytes32 taskId) external view returns (bytes memory);

    /// @notice return the array of Task unique identifiers
    function taskIds() external view returns (bytes32[] memory);

    /// @notice return true if the identifier corresponds to an existing Task, else false
    function isTaskId(bytes32 taskId) external view returns (bool);

    /// @notice convert a Task struct into its' associated bytes
    function encodeTask(Task memory task) external pure returns (bytes memory);

    /// @notice Return the unique identifier of a Task
    function calcTaskId(Task memory task) external pure returns (bytes32);
}
