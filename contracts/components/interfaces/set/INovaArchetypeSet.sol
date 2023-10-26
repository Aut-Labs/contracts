// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface INovaArchetypeSet {

    function setArchetype(uint8) external;

    function setWeightFor(uint8, uint256) external;
}
