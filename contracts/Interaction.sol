//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./IDAOExpander.sol";

contract Interaction {
    event InteractionIndexIncreased(address member, uint256 total);
    event AllowedAddress(address addr);
    using Counters for Counters.Counter;

    Counters.Counter private idCounter;

    mapping(address => bool) isAllowed;

    struct InteractionModel {
        address member;
        uint256 taskID;
        address contractAddress;
    }

    modifier onlyAllowed() {
        require(isAllowed[msg.sender], 'Not allowed to transfer interactions');
        _;
    }

    mapping(uint256 => InteractionModel) interactions;
    mapping(address => uint256) interactionsIndex;

    IDAOExpander public daoExpander;
    address public discordBotAddress;

    constructor() {
        daoExpander = IDAOExpander(msg.sender);
    }

    function allowAccess(address addr) public {
        require(daoExpander.isAdmin(msg.sender), 'Not an admin');
        isAllowed[addr] = true;

        emit AllowedAddress(addr);
    }

    function addInteraction(uint256 activityID, address member) public onlyAllowed {
        InteractionModel memory model = InteractionModel(member, activityID, msg.sender);

        idCounter.increment();
        interactions[idCounter.current()] = model;
        interactionsIndex[member]++;

        emit InteractionIndexIncreased(member, interactionsIndex[member]);
    }

    // view
    function getInteraction(uint256 interactionID)
        public
        view
        returns (InteractionModel memory)
    {
        return interactions[interactionID];
    }

    function getInteractionsIndexPerAddress(address user)
        public
        view
        returns (uint256)
    {
        return interactionsIndex[user];
    }
}
