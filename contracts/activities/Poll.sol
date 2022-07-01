//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Interaction.sol";
import "../ICommunityExtension.sol";
import "../IAutID.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Polls {
    using Counters for Counters.Counter;

    event PollCreated(uint256 _id, string _uri);
    event PollClosed(uint256 _id, string _uri);

    address public discordBot;
    Counters.Counter private idCounter;

    Poll[] private polls;
    address public communityExtension;

    struct Poll {
        uint256 timestamp;
        string pollData;
        string results;
        bool isFinalized;
        uint256 role;
        uint256 dueDate;
    }

    modifier onlyDiscordBot() {
        require(discordBot == msg.sender, "Only discord bot!");
        _;
    }

    constructor(address _communityExtension, address _discordBot) {
        require(_communityExtension != address(0), "no community address");
        require(ICommunityExtension(_communityExtension).isCoreTeam(msg.sender), "Only core team!");

        communityExtension = _communityExtension;
        discordBot = _discordBot;
    }

    function create(
        uint256 _role,
        uint256 _dueDate,
        string memory _uri
    ) public returns (uint256) {
        require(bytes(_uri).length > 0, "No URI");

        uint256 pollID = idCounter.current();

        polls.push(Poll(block.timestamp, _uri, "", false, _role, _dueDate));
        idCounter.increment();

        emit PollCreated(pollID, _uri);
        return pollID;
    }

    function close(
        uint256 pollID,
        string calldata results,
        address[] calldata participants
    ) public onlyDiscordBot {
        require(
            polls[pollID].dueDate < block.timestamp,
            "Due date not reached yet."
        );
        require(!polls[pollID].isFinalized, "already finalized");
        require(bytes(results).length > 0, "Results file empty");

        for (uint256 i = 0; i < participants.length; i++) {
            if (
                ICommunityExtension(communityExtension).isMemberOfExtendedDAO(
                    participants[i]
                ) &&
                uint256(
                    IAutID(
                        ICommunityExtension(communityExtension).autIDAddr()
                    ).getCommunityData(participants[i], communityExtension).role
                ) ==
                polls[pollID].role
            )
                Interaction(
                    ICommunityExtension(communityExtension)
                        .getInteractionsAddr()
                ).addInteraction(pollID, participants[i]);
        }

        polls[pollID].isFinalized = true;
        polls[pollID].results = results;

        emit PollClosed(pollID, results);
    }

    function getById(uint id) public view returns(Poll memory poll) {
        return polls[id];
    }

    function getIDCounter() public view returns(uint) {
        return idCounter.current() - 1;
    }
}
