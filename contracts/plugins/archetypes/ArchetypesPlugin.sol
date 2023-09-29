// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "./IArchetypesPlugin.sol";

contract ArchetypesPlugin is IArchetypesPlugin {
    uint8 public mainArchetype;
    mapping(uint8 => uint256) public archetypeWeightFor;

    function setMainArchetype(uint8 archetype) external {
        require(mainArchetype == 0, ArchetypeAlreadySet());
        _validateArchetype(archetype);
        mainArchetype = archetype;
    }

    function setArchetypeWeightFor(uint8 archetype, uint256 value) external {
        _validateArchetype(archetype);
        archetypeWeightFor[archetype] = value;
    }

    function _validateArchetype(uint8 archetype) internal {
        require(archetype <= 5 && archetype != 0, WrongArchetype());
    }
}
