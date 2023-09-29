// //SPDX-License-Identifier: MIT
// pragma solidity 0.8.19;

// import "../interfaces/get/IDAOInteractions.sol";
// import "../../Interaction.sol";

// /// @title DAOExpander
// /// @notice The extension of each DAO that integrates Aut
// /// @dev The extension of each DAO that integrates Aut
// abstract contract DAOInteractions is IDAOInteractions {
//     Interaction private interactions;

//     function _deployInteractions() internal {
//         require(address(interactions) == address(0));
//         interactions = new Interaction();
//     }

//     function getInteractionsAddr() public view override returns (address) {
//         return address(interactions);
//     }

//     function getInteractionsPerUser(address member) public view override returns (uint256) {
//         return interactions.getInteractionsIndexPerAddress(member);
//     }
// }
