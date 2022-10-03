//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Interaction.sol";
import "../expander/interfaces/IDAOExpander.sol";
import "../IAutID.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CommunityCalls {
    using Counters for Counters.Counter;

    event CommunityCallCreated(uint256 _id, string _uri);
    event CommunityCallClosed(uint256 _id, string _uri);

    address public discordBot;
    Counters.Counter private idCounter;

    CommunityCall[] private comCalls;
    IDAOExpander daoExpander;

    struct CommunityCall {
        uint256 timestamp;
        string comCallDetails;
        string results;
        bool isFinalized;
        uint256 role;
        uint256 startTime;
        uint256 endTime;
    }

    modifier onlyDiscordBot() {
        require(discordBot == msg.sender, "Only discord bot!");
        _;
    }

    constructor(IDAOExpander _daoExpander, address _discordBot) {
        require(address(_daoExpander) != address(0), "no community address");
        require(_discordBot != address(0), "no discord bot address");

        daoExpander = _daoExpander;
        discordBot = _discordBot;
    }

    function setDiscordAddress(address _discordBot) public {
        require(
            IDAOExpander(daoExpander).isAdmin(msg.sender),
            "Only admin!"
        );
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

        comCalls.push(
            CommunityCall(
                block.timestamp,
                _uri,
                "",
                false,
                _role,
                _startTime,
                _endTime
            )
        );

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
            comCalls[comCallID].startTime > block.timestamp &&
                comCalls[comCallID].endTime > block.timestamp,
            "Due date not reached yet."
        );
        require(!comCalls[comCallID].isFinalized, "already finalized");
        require(bytes(results).length > 0, "Results file empty");

        for (uint256 i = 0; i < participants.length; i++) {
            if (
                daoExpander.isMember(participants[i]) &&
                uint256(
                    IAutID(daoExpander.autIDAddr())
                        .getMembershipData(
                            participants[i],
                            address(daoExpander)
                        )
                        .role
                ) ==
                comCalls[comCallID].role
            )
                Interaction(daoExpander.getInteractionsAddr()).addInteraction(
                    comCallID,
                    participants[i]
                );
        }

        emit CommunityCallClosed(comCallID, results);
    }
}
