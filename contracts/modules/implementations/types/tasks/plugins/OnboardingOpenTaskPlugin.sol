//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../../../../../daoUtils/interfaces/get/IDAOInteractions.sol";
import "../../../../../IInteraction.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../../../../interfaces/modules/tasks/TasksModule.sol";
import "../../SimplePlugin.sol";

contract OnboardingOpenTaskPlugin is TasksModule, SimplePlugin {
    using Counters for Counters.Counter;

    Counters.Counter private idCounter;
    Task[] public tasks;

    struct OnboardingTaskDetails {
        uint completionTime;
        TaskStatus status;
    }

    mapping(uint256 => mapping(address => OnboardingTaskDetails)) taskStatusDetails;

    modifier atStatus(
        uint256 taskID,
        address user,
        TaskStatus status
    ) {
        if (status != taskStatusDetails[taskID][user].status)
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

    constructor(address dao) SimplePlugin(dao) {
        tasks.push(
            Task(0, TaskStatus.Created, address(0), address(0), "", 0, "", 0, 0)
        );
        idCounter.increment();
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

    // not implemented
    function submit(uint256 taskId, string calldata submitionUrl)
        public
        override
        atStatus(taskId, msg.sender, TaskStatus.Created)
    {
        taskStatusDetails[taskId][msg.sender].status = TaskStatus.Submitted;
        tasks[taskId].submitionUrl = submitionUrl;

        emit TaskSubmitted(taskId);
    }

    function finalizeFor(uint256 taskId, address submitter)
        public
        override
        atStatus(taskId, submitter, TaskStatus.Submitted)
        onlyCreator(taskId)
    {
        require(tasks[taskId].startDate < block.timestamp, "Not started yet");
        require(tasks[taskId].endDate > block.timestamp, "The task has ended");

        taskStatusDetails[taskId][submitter].status = TaskStatus.Finished;
        taskStatusDetails[taskId][submitter].completionTime = block.timestamp;

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

    function getStatusPerSubmitter(uint256 taskId, address submitter)
        public
        override
        view
        returns (TaskStatus)
    {
        return taskStatusDetails[taskId][submitter].status;
    }

    function getCompletionTime(uint256 taskId, address user)
        public
        override
        view
        returns (uint)
    {
        return taskStatusDetails[taskId][user].completionTime;
    }


    function hasCompletedTheTask(address user, uint256 taskId)
        public
        view
        override
        returns (bool)
    {
        return taskStatusDetails[taskId][user].status == TaskStatus.Finished;
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

    function take(uint256 taskId) public override {
        revert FunctionNotImplemented();
    }

    function finalize(uint256 taskId) public override {
        revert FunctionNotImplemented();
    }
}
