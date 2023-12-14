// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.20;

// import "../interfaces/get/INovaArchetype.sol";

// abstract contract NovaArchetype is INovaArchetype {
//     uint8 public constant SIZE = 1;
//     uint8 public constant REPUTATION = 2;
//     uint8 public constant CONVICTION = 3;
//     uint8 public constant PERFORMANCE = 4;
//     uint8 public constant GROWTH = 5;

//     uint8 public archetype;
//     mapping(uint8 => uint256) public weightFor;

//     function _setArchetype(uint8 parameter) internal {
//         _validateParameter(parameter);
//         archetype = parameter;
//     }

//     function _setWeightFor(uint8 parameter, uint256 value) internal {
//         _validateParameter(parameter);
//         weightFor[parameter] = value;
//     }

//     function _validateParameter(uint8 parameter) internal pure {
//         if (parameter > 5 || parameter == 0) {
//             revert WrongParameter();
//         }
//     }

//     uint256[48] private __gap;
// }
