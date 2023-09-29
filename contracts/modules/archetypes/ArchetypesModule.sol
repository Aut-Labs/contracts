// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "../IModule.sol";

interface ArchetypesModule is IModule {
    error ArchetypeAlreadySet();
    error WrongArchetype();

    event MainArchetypeSet(uint8);
    event ArchetypeWeightSet(uint8, uint256);

    uint8 public constant SIZE = 1;
    uint8 public constant REPUTATION = 2;
    uint8 public constant CONVICTION = 3;
    uint8 public constant PERFORMANCE = 4;
    uint8 public constant GROWTH = 5;

    function mainArchetype() external view returns(uint8);

    function archetypeWeightFor(uint8) external view returns(uint256);

    function setMainArchetype(uint8) external;

    function setArchetypeWeightFor(uint8, uint256) external;
}
