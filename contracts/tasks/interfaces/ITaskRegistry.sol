pragma solidity >=0.8.0;

struct Task {
    string uri;
    // TODO: other identifiers / metadata?
}

interface ITaskRegistry {
    error TaskAlreadyRegistered();
    error TaskNotRegistered();

    event RegisterTask(bytes32 indexed taskId, address indexed who, string uri);

    function registerTasks(Task[] calldata tasks) external returns (bytes32[] memory);
    function registerTask(Task memory task) external returns (bytes32);

    function getTaskById(bytes32 taskId) external view returns (Task memory);
    function getTaskByIdEncoded(bytes32 taskId) external view returns (bytes memory);
    function taskIds() external view returns (bytes32[] memory);
    function isTaskId(bytes32 taskId) external view returns (bool);

    function encodeTask(Task memory task) external pure returns (bytes memory);
    function calcTaskId(Task memory task) external pure returns (bytes32);
}
