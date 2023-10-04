// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "../IModule.sol";

interface ArchetypesModule is IModule {
    error ArchetypeAlreadySet();
    error WrongArchetype();

    event MainArchetypeSet(uint8);
    event ArchetypeWeightSet(uint8, uint256);

    function SIZE() external pure returns(uint8);

    function REPUTATION() external pure returns(uint8);

    function CONVICTION() external pure returns(uint8);

    function PERFORMANCE() external pure returns(uint8);

    function GROWTH() external pure returns(uint8);

    function rchetype() external view returns(uint8);

    function archetypeWeightFor(uint8) external view returns(uint256);

    function setMainArchetype(uint8) external;

    function setArchetypeWeightFor(uint8, uint256) external;
}
