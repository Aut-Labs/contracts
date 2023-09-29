// //SPDX-License-Identifier: MIT
// pragma solidity 0.8.19;

// import "@openzeppelin/contracts/utils/Counters.sol";
// import "./daoUtils/interfaces/get/IDAOAdmin.sol";

// interface IInteraction {
//     event InteractionIndexIncreased(address member, uint256 total);
//     event AddressAllowed(address addr);

//     struct InteractionModel {
//         address member;
//         uint256 taskID;
//         address contractAddress;
//     }

//     function dao() external view returns (IDAOAdmin);

//     function allowAccess(address addr) external;

//     function addInteraction(uint256 activityID, address member) external;

//     // view
//     function getInteraction(uint256 interactionID) external view returns (InteractionModel memory);

//     function getInteractionsIndexPerAddress(address user) external view returns (uint256);
// }
