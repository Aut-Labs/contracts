//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Interaction.sol";
import "../ICommunityExtension.sol";
import "../IAutID.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CommunityCalls {
    using Counters for Counters.Counter;

    event CommunityCallCreated(uint256 _id, string _uri);
    event CommunityCallClosed(uint256 _id, string _uri);

    address public discordBot;
    Counters.Counter private idCounter;

    CommunityCall[] private comCalls;
    address communityExtension;

    struct CommunityCall {
        uint256 timestamp;
        string comCallDetails;
        string results;
        bool isFinalized;
        uint256 role;
        uint256 startTime;
        uint256 endTime;
    }

    /// @dev Modifier for check of access of the core team member functions
    modifier onlyDiscordBot() {
        require(discordBot == msg.sender, "Only discord bot!");
        _;
    }

    constructor(address _communityExtension, address _discordBot) {
        require(_communityExtension != address(0), "no community address");

        communityExtension = _communityExtension;
        discordBot = _discordBot;
    }

    function setDiscordAddress(address _discordBot) public { 
        require(ICommunityExtension(communityExtension).isCoreTeam(msg.sender), "Only Core team!");
        discordBot = _discordBot;
    }

    function create(
        uint256 _role,
        uint256 _startTime,
        uint256 _endTime,
        string memory _uri
    ) public returns (uint256) {
        require(bytes(_uri).length > 0, "No URI");

        uint256 comCallID = idCounter.current();

        comCalls.push(CommunityCall(block.timestamp, _uri, "", false, _role, _startTime, _endTime));

        idCounter.increment();
        emit CommunityCallCreated(comCallID, _uri);
        return comCallID;
    }

    function close(
        uint256 comCallID,
        string calldata results,
        address[] calldata participants
    ) public onlyDiscordBot {
        require(
            comCalls[comCallID].startTime > block.timestamp && comCalls[comCallID].endTime > block.timestamp,
            "Due date not reached yet."
        );
        require(!comCalls[comCallID].isFinalized, "already finalized");
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
                comCalls[comCallID].role
            )
                Interaction(
                    ICommunityExtension(communityExtension)
                        .getInteractionsAddr()
                ).addInteraction(comCallID, participants[i]);
        }

        emit CommunityCallClosed(comCallID, results);
    }
}
