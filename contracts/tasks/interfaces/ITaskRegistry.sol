pragma solidity >=0.8.0;

struct TaskType {
    string description;
    bytes32 interactionId;
}

interface ITaskRegistry {
    error TaskAlreadyRegistered();
    error TaskNotRegistered();

    function registeredTaskSet() external view returns (bytes32[] memory);
    function registeredTasks(bytes32 taskId) external view returns (TaskType memory);
    function isRegisteredTask(bytes32 taskId) external view returns (bool);

    function registerTasks(TaskType[] calldata tasks) external;
    function registerTask(TaskType memory task) external;
    function unregisterTasks(TaskType[] calldata tasks) external;
    function unregisterTask(TaskType calldata task) external;

    function encodeTask(TaskType memory task) external pure returns (bytes32);
}
