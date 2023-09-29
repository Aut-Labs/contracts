// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "./IArchetypesPlugin.sol";
import "../SimplePlugin.sol";

contract ArchetypesPlugin is IArchetypesPlugin, SimplePlugin {
    uint8 public mainArchetype;
    mapping(uint8 => uint256) public archetypeWeightFor;

    constructor(address dao) {
        _dao = dao;
        _deployer = msg.sender;
    }

    function setMainArchetype(uint8 archetype) external onlyOwner {
        require(mainArchetype == 0, ArchetypeAlreadySet());
        _validateArchetype(archetype);
        mainArchetype = archetype;   
        _setActive(true);
    }

    function setArchetypeWeightFor(
        uint8 archetype,
        uint256 value
    )
        external
        onlyOwner 
    {
        _validateArchetype(archetype);
        archetypeWeightFor[archetype] = value;
    }

    function _validateArchetype(uint8 archetype) internal {
        require(archetype <= 5 && archetype != 0, WrongArchetype());
    }
}
