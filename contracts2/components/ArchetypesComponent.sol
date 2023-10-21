// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "../base/ComponentBase.sol";
import "../utils/Semver.sol";

interface IArchetype {
    error ArchetypeAlreadySet();
    error WrongParameter();

    event MainArchetypeSet(uint8);
    event ArchetypeWeightSet(uint8, uint256);

    function archetype() external view returns(uint8);

    function weightFor(uint8) external view returns(uint256);

    function setArchetype(uint8) external;

    function setWeightFor(uint8, uint256) external;
}

contract ArchetypeComponent is ComponentBase, IArchetype, Semver(0, 1, 0) {
    uint8 public constant SIZE = 1;
    uint8 public constant REPUTATION = 2;
    uint8 public constant CONVICTION = 3;
    uint8 public constant PERFORMANCE = 4;
    uint8 public constant GROWTH = 5;

    uint8 public archetype;
    mapping(uint8 => uint256) public weightFor;

    function setArchetype(uint8 parameter) external {
        if (archetype != 0) {
            revert ArchetypeAlreadySet();
        }
        _validateParameter(parameter);
        archetype = parameter;
    }

    function setWeightFor(
        uint8 parameter,
        uint256 value
    )
        external 
    {
        _validateParameter(parameter);
        weightFor[parameter] = value;
    }

    function _validateParameter(uint8 parameter) internal pure {
        if (parameter > 5 || parameter == 0) {
            revert WrongParameter();
        }
    }
}
