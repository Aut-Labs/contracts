pragma solidity >=0.8.0;

struct BasicTask {
    string description;
    bytes32 interactionId;
}

interface ITaskRegistry {
    error TaskAlreadyRegistered();
    error TaskNotRegistered();

    function registeredTaskSet() external view returns (bytes32[] memory);
    function isRegisteredTask(bytes32 taskId) external view returns (bool);

    function registerTasks(BasicTask[] calldata tasks) external;
    function registerTask(BasicTask memory task) external;
    function unregisterTasks(BasicTask[] calldata tasks) external;
    function unregisterTask(BasicTask calldata task) external;

    function encodeTask(BasicTask memory task) external pure returns (bytes32);
}
