//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "../SimplePlugin.sol";
import "../../IInteraction.sol";

import "../../modules/tasks/TasksModule.sol";
import "../../daoUtils/interfaces/get/IDAOInteractions.sol";
import "../../daoUtils/interfaces/get/IDAOMembership.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

contract OpenTaskPlugin is TasksModule, SimplePlugin {
    using Counters for Counters.Counter;

    Counters.Counter public idCounter;
    Counters.Counter public submissionIds;

    Task[] public tasks;

    bool public daoMembersOnly;

    struct Submission {
        address submitter;
        string submissionMetadata;
        uint256 completionTime;
        TaskStatus status;
    }

    mapping(uint => uint[]) public taskSubmissions;
    mapping(uint => mapping(address => uint)) submitterToSubmissionId;

    Submission[] public submissions;

    modifier atStatus(
        uint256 taskID,
        address user,
        TaskStatus status
    ) {
        if (status != submissions[submitterToSubmissionId[taskID][user]].status)
            revert FunctionInvalidAtThisStage();
        _;
    }

    modifier onlyAllowedToSubmit() {
        if (daoMembersOnly)
            require(
                IDAOMembership(_dao).isMember(msg.sender),
                "Only DAO members"
            );
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

    constructor(address dao, bool membersOnly) SimplePlugin(dao, 0) {
        tasks.push(Task(0, address(0), 0, "", 0, 0));
        submissions.push(Submission(address(0), "", 0, TaskStatus.Created));
        idCounter.increment();
        submissionIds.increment();

        daoMembersOnly = membersOnly;
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
            Task(block.timestamp, creator, role, uri, startDate, endDate)
        );

        idCounter.increment();
        emit TaskCreated(taskId, uri);
        return taskId;
    }

    function submit(
        uint256 taskId,
        string calldata submitionUrl
    )
        public
        override
        onlyAllowedToSubmit
        atStatus(taskId, msg.sender, TaskStatus.Created)
    {
        uint256 submissionId = submissionIds.current();
        submissions.push(
            Submission(msg.sender, submitionUrl, 0, TaskStatus.Submitted)
        );
        taskSubmissions[taskId].push(submissionId);
        submitterToSubmissionId[taskId][msg.sender] = submissionId;
        submissionIds.increment();
        emit TaskSubmitted(taskId, submissionId);
    }

    function finalizeFor(
        uint256 taskId,
        address submitter
    )
        public
        override
        atStatus(taskId, submitter, TaskStatus.Submitted)
        onlyCreator(taskId)
    {
        require(tasks[taskId].startDate < block.timestamp, "Not started yet");
        require(tasks[taskId].endDate > block.timestamp, "The task has ended");

        submissions[submitterToSubmissionId[taskId][submitter]]
            .status = TaskStatus.Finished;
        submissions[submitterToSubmissionId[taskId][submitter]]
            .completionTime = block.timestamp;

        IInteraction(IDAOInteractions(daoAddress()).getInteractionsAddr())
            .addInteraction(taskId, submitter);

        emit TaskFinalized(taskId, submitter);
    }

    function getById(
        uint256 taskId
    ) public view override returns (Task memory) {
        return tasks[taskId];
    }

    function getStatusPerSubmitter(
        uint256 taskId,
        address submitter
    ) public view override returns (TaskStatus) {
        return submissions[submitterToSubmissionId[taskId][submitter]].status;
    }

    function getSubmissionIdsPerTask(
        uint taskId
    ) public view returns (uint[] memory) {
        return taskSubmissions[taskId];
    }

    function getSubmissionIdPerTaskAndUser(
        uint taskId,
        address submitter
    ) public view returns (uint) {
        return submitterToSubmissionId[taskId][submitter];
    }

    function getCompletionTime(
        uint256 taskId,
        address user
    ) public view override returns (uint256) {
        return
            submissions[submitterToSubmissionId[taskId][user]].completionTime;
    }

    function hasCompletedTheTask(
        address user,
        uint256 taskId
    ) public view override returns (bool) {
        return
            submissions[submitterToSubmissionId[taskId][user]].status ==
            TaskStatus.Finished;
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
            Task(block.timestamp, msg.sender, role, uri, startDate, endDate)
        );

        idCounter.increment();
        emit TaskCreated(taskId, uri);
        return taskId;
    }

    function take(uint256 taskId) public override {
        revert FunctionNotImplemented();
    }

    function finalize(uint256 taskId) public override {
        revert FunctionNotImplemented();
    }
}
