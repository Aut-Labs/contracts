//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Interaction.sol";
import "../ICommunityExtension.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Tasks {
    using Counters for Counters.Counter;

    event TaskCreated(uint256 _taskId, string _uri);
    event TaskTaken(uint256 _taskId, address _taker);
    event TaskSubmitted(uint256 _taskId);
    event TaskFinalized(uint256 _taskId, address _taker);

    enum TaskStatus {
        Created,
        Taken,
        Submitted,
        Finished
    }

    struct Task {
        uint256 createdOn;
        TaskStatus status;
        address creator;
        address taker;
        string submitionUrl;
        uint256 role;
        string metadata;
    }

    Counters.Counter private idCounter;

    address public communityExtension;

    Task[] public tasks;
    mapping(uint256 => bool) public isFinalized;

    constructor(address _communityExtension) {
        require(_communityExtension != address(0), "no community address");

        communityExtension = _communityExtension;
    }

    //core team member task functions
    function create(uint256 _role, string memory _uri)
        public
        returns (uint256)
    {
        require(bytes(_uri).length > 0, "No URI");
        uint256 taskId = idCounter.current();

        tasks.push(
            Task(
                block.timestamp,
                TaskStatus.Created,
                msg.sender,
                address(0),
                "",
                _role,
                _uri
            )
        );

        idCounter.increment();
        emit TaskCreated(taskId, _uri);
        return taskId;
    }

    function take(uint256 taskId) public {
        require(tasks[taskId].status == TaskStatus.Created, "wrong status");
        require(
            tasks[taskId].creator != msg.sender,
            "Creator can't take the task."
        );

        tasks[taskId].taker = msg.sender;
        tasks[taskId].status = TaskStatus.Taken;

        emit TaskTaken(taskId, msg.sender);
    }

    function submit(uint256 taskId, string calldata submitionUrl) public {
        require(tasks[taskId].status == TaskStatus.Taken, "wrong status");
        require(
            tasks[taskId].taker == msg.sender,
            "Only taker can submit a task."
        );

        tasks[taskId].status = TaskStatus.Submitted;
        tasks[taskId].submitionUrl = submitionUrl;

        emit TaskSubmitted(taskId);
    }

    function finalize(uint256 taskId) public {
        require(
            tasks[taskId].creator == msg.sender,
            "Only creator can finalize!"
        );
        require(tasks[taskId].status == TaskStatus.Submitted, "wrong status");

        tasks[taskId].status = TaskStatus.Finished;
        isFinalized[taskId] = true;

        Interaction(
            ICommunityExtension(communityExtension).getInteractionsAddr()
        ).addInteraction(taskId, tasks[taskId].taker);

        emit TaskFinalized(taskId, tasks[taskId].taker);
    }

    function getById(uint256 taskId) public view returns (Task memory) {
        return tasks[taskId];
    }
}
