//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../SimplePlugin.sol";
import "../../IInteraction.sol";

import "../../modules/tasks/TasksModule.sol";
import "../../daoUtils/interfaces/get/IDAOInteractions.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

contract OffchainVerifiedTaskPlugin is TasksModule, SimplePlugin {
    using Counters for Counters.Counter;

    Counters.Counter public idCounter;
    Task[] public tasks;
    address public _offchainVerifierAddress;

    struct TaskDetails {
        uint256 completionTime;
        TaskStatus status;
    }

    mapping(uint256 => mapping(address => TaskDetails)) taskStatuses;

    constructor(
        address dao,
        address offchainVerifierAddress
    ) SimplePlugin(dao, 0) {
        _offchainVerifierAddress = offchainVerifierAddress;
        tasks.push(Task(0, address(0), 0, "", 0, 0));
        idCounter.increment();
    }

    modifier atStatus(uint256 taskID, TaskStatus status) {
        if (status != taskStatuses[taskID][msg.sender].status)
            revert FunctionInvalidAtThisStage();
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

    function createBy(
        address creator,
        uint256 role,
        string memory uri,
        uint256 startDate,
        uint256 endDate
    ) public override returns (uint256) {
        require(endDate > block.timestamp, "Invalid endDate");
        require(bytes(uri).length > 0, "No URI");
        uint256 taskId = idCounter.current();

        tasks.push(
            Task(block.timestamp, creator, role, uri, startDate, endDate)
        );

        idCounter.increment();

        emit TaskCreated(taskId, uri);
        return taskId;
    }

    function editTask(
        uint256 taskId,
        uint256 role,
        string memory uri,
        uint256 startDate,
        uint256 endDate
    ) public override onlyAdmin {
        require(tasks[taskId].startDate > block.timestamp, "task already started");
        require(bytes(uri).length > 0, "No URI");
        require(taskId < idCounter.current(), "invalid task");

        tasks[taskId].role = role;
        tasks[taskId].metadata = uri;
        tasks[taskId].startDate = startDate;
        tasks[taskId].endDate = endDate;

        emit TaskEdited(taskId, uri);
    }

    function finalizeFor(
        uint256 taskId,
        address submitter
    ) public override onlyOffchainVerifier {
        require(tasks[taskId].startDate <= block.timestamp, "Not started yet");
        require(tasks[taskId].endDate >= block.timestamp, "The task has ended");

        taskStatuses[taskId][submitter].status = TaskStatus.Finished;
        taskStatuses[taskId][submitter].completionTime = block.timestamp;

        IInteraction(IDAOInteractions(daoAddress()).getInteractionsAddr())
            .addInteraction(taskId, submitter);

        emit TaskFinalized(taskId, submitter);
    }

    function getById(
        uint256 taskId
    ) public view override returns (Task memory) {
        return tasks[taskId];
    }

    function setOffchainVerifierAddress(
        address offchainVerifierAddress
    ) public onlyAdmin {
        _offchainVerifierAddress = offchainVerifierAddress;
    }

    function getStatusPerSubmitter(
        uint256 taskId,
        address submitter
    ) public view override returns (TaskStatus) {
        return taskStatuses[taskId][submitter].status;
    }

    function getCompletionTime(
        uint256 taskId,
        address user
    ) public view override returns (uint256) {
        return taskStatuses[taskId][user].completionTime;
    }

    function hasCompletedTheTask(
        address user,
        uint256 taskId
    ) public view override returns (bool) {
        return taskStatuses[taskId][user].status == TaskStatus.Finished;
    }

    // not implemented
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
            Task(block.timestamp, msg.sender, role, uri, startDate, endDate)
        );

        idCounter.increment();
        emit TaskCreated(taskId, uri);
        return taskId;
    }

    function take(uint256 taskId) public override {
        revert FunctionNotImplemented();
    }

    function submit(
        uint256 taskId,
        string calldata submitionUrl
    ) public override {
        revert FunctionNotImplemented();
    }

    function finalize(uint256 taskId) public override {
        revert FunctionNotImplemented();
    }
}
