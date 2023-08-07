//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./daoUtils/interfaces/get/IDAOAdmin.sol";
import "./daoUtils/interfaces/get/IDAOModules.sol";
import "./IInteraction.sol";

contract Interaction is IInteraction {
    using Counters for Counters.Counter;

    Counters.Counter private idCounter;

    mapping(address => bool) isAllowed;

    modifier onlyAllowed() {
        require(isAllowed[msg.sender], "Not allowed to transfer interactions");
        _;
    }

    mapping(uint256 => InteractionModel) interactions;
    mapping(address => uint256) interactionsIndex;

    IDAOAdmin public override dao;

    constructor() {
        dao = IDAOAdmin(msg.sender);
    }

    function allowAccess(address addr) public override {
        require(dao.isAdmin(msg.sender) || IDAOModules(address(dao)).pluginRegistry() == msg.sender, "Not allowed");
        isAllowed[addr] = true;

        emit AddressAllowed(addr);
    }

    function addInteraction(uint256 activityID, address member) public override onlyAllowed {
        InteractionModel memory model = InteractionModel(member, activityID, msg.sender);

        idCounter.increment();
        interactions[idCounter.current()] = model;
        interactionsIndex[member]++;

        emit InteractionIndexIncreased(member, interactionsIndex[member]);
    }

    // view
    function getInteraction(uint256 interactionID) public view override returns (InteractionModel memory) {
        return interactions[interactionID];
    }

    function getInteractionsIndexPerAddress(address user) public view override returns (uint256) {
        return interactionsIndex[user];
    }
}
