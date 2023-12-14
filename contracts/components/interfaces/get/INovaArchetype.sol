// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface INovaArchetype {
    error ArchetypeAlreadySet();
    error WrongParameter();

    event MainArchetypeSet(uint8);
    event ArchetypeWeightSet(uint8, uint256);

    function archetype() external view returns (uint8);

    function weightFor(uint8) external view returns (uint256);
}
