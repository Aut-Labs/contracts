//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../../../../daoUtils/interfaces/get/IDAOInteractions.sol";
import "../../../../../IInteraction.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../../../../interfaces/modules/tasks/TasksModule.sol";
import "../../SimplePlugin.sol";

contract OffchainVerifiedTaskPlugin is TasksModule, SimplePlugin {
    using Counters for Counters.Counter;

    Counters.Counter private idCounter;
    Task[] public tasks;
    address public _offchainVerifierAddress;

    struct OnboardingTaskDetails {
        address taker;
        TaskStatus status;
    }

    mapping(uint256 => mapping(address => TaskStatus)) taskStatuses;

    constructor(address dao, address offchainVerifierAddress)
        SimplePlugin(dao)
    {
        _offchainVerifierAddress = offchainVerifierAddress;
        tasks.push(
            Task(0, TaskStatus.Created, address(0), address(0), "", 0, "", 0, 0)
        );
        idCounter.increment();
    }

    modifier atStatus(uint256 taskID, TaskStatus status) {
        if (
            status != tasks[taskID].status ||
            status != taskStatuses[taskID][msg.sender]
        ) revert FunctionInvalidAtThisStage();
        _;
    }

    modifier onlyCreator(uint256 taskID) {
        require(tasks[taskID].creator == msg.sender, "Only creator.");
        _;
    }

    modifier onlyAdmin() {
        require(IDAOAdmin(_dao).isAdmin(msg.sender), "Only admin.");
        _;
    }

    modifier onlyOffchainVerifier() {
        require(
            _offchainVerifierAddress == msg.sender,
            "Only offchain verifier."
        );
        _;
    }

    function create(
        uint256 role,
        string memory uri,
        uint256 startDate,
        uint256 endDate
    ) public override onlyAdmin returns (uint256) {
        require(endDate > block.timestamp, "Invalid endDate");
        require(bytes(uri).length > 0, "No URI");
        uint256 taskId = idCounter.current();

        tasks.push(
            Task(
                block.timestamp,
                TaskStatus.Created,
                msg.sender,
                address(0),
                "",
                role,
                uri,
                startDate,
                endDate
            )
        );

        idCounter.increment();
        emit TaskCreated(taskId, uri);
        return taskId;
    }

    function createBy(
        address creator,
        uint256 role,
        string memory uri,
        uint256 startDate,
        uint256 endDate
    ) public override onlyDAOModule returns (uint256) {
        require(endDate > block.timestamp, "Invalid endDate");
        require(bytes(uri).length > 0, "No URI");
        uint256 taskId = idCounter.current();

        tasks.push(
            Task(
                block.timestamp,
                TaskStatus.Created,
                creator,
                address(0),
                "",
                role,
                uri,
                startDate,
                endDate
            )
        );

        idCounter.increment();
        emit TaskCreated(taskId, uri);
        return taskId;
    }

    function take(uint256 taskId) public override {
        revert FunctionNotImplemented();
    }

    function submit(uint256 taskId, string calldata submitionUrl)
        public
        override
    {
        revert FunctionNotImplemented();
    }

    function finalize(uint256 taskId) public override {
        revert FunctionNotImplemented();
    }

    function finalizeFor(uint256 taskId, address submitter)
        public
        override
        onlyOffchainVerifier
    {
        require(tasks[taskId].startDate < block.timestamp, "Not started yet");
        require(tasks[taskId].endDate > block.timestamp, "The task has ended");

        taskStatuses[taskId][submitter] = TaskStatus.Finished;

        IInteraction(IDAOInteractions(daoAddress()).getInteractionsAddr())
            .addInteraction(taskId, submitter);

        emit TaskFinalized(taskId, submitter);
    }

    function getById(uint256 taskId)
        public
        view
        override
        returns (Task memory)
    {
        return tasks[taskId];
    }

    function setOffchainVerifierAddress(address offchainVerifierAddress)
        public
        onlyAdmin
    {
        _offchainVerifierAddress = offchainVerifierAddress;
    }

    function getStatusPerSubmitter(uint256 taskId, address submitter)
        public
        view
        returns (TaskStatus)
    {
        return taskStatuses[taskId][submitter];
    }

    function hasCompletedTheTask(address user, uint256 taskId)
        public
        view
        override
        returns (bool)
    {
        return taskStatuses[taskId][user] == TaskStatus.Finished;
    }
}
