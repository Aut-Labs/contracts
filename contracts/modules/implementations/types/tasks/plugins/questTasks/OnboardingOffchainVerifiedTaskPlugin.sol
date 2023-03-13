//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";

import "../../../../../../daoUtils/interfaces/get/IDAOInteractions.sol";
import "../../../../../../IInteraction.sol";
import "../../../../../interfaces/modules/tasks/QuestTasksModule.sol";
import "../../../../../interfaces/modules/quest/QuestsModule.sol";
import "../../../SimplePlugin.sol";

contract OnboardingQuestOffchainVerifiedTaskPlugin is
    QuestTasksModule,
    SimplePlugin
{
    using Counters for Counters.Counter;

    Counters.Counter public idCounter;
    Task[] public tasks;
    address public _offchainVerifierAddress;

    QuestsModule quests;

    struct OnboardingTaskDetails {
        uint256 completionTime;
        TaskStatus status;
    }

    mapping(uint256 => mapping(address => OnboardingTaskDetails)) taskStatuses;

    constructor(
        address dao,
        address offchainVerifierAddress,
        address questsAddress
    ) SimplePlugin(dao) {
        _offchainVerifierAddress = offchainVerifierAddress;
        tasks.push(Task(0, address(0), 0, "", 0, 0));
        idCounter.increment();

        quests = QuestsModule(questsAddress);
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

    modifier onlyQuests() {
        require(address(quests) == msg.sender, "Only quests.");
        _;
    }

    function createBy(
        address creator,
        uint256 role,
        string memory uri,
        uint256 startDate,
        uint256 endDate
    ) public override onlyQuests returns (uint256) {
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

    function finalizeFor(
        uint256 taskId,
        address submitter
    ) public override onlyOffchainVerifier {
        require(address(quests) != address(0), "not linked to a quest");
        require(tasks[taskId].startDate < block.timestamp, "Not started yet");
        require(tasks[taskId].endDate > block.timestamp, "The task has ended");

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

    function setQuestsAddress(address questsAddress) public override onlyAdmin {
        quests = QuestsModule(questsAddress);
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
