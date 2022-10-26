//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IDAOMarket.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title DAOExpander
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
interface IMarket {

    event AddedMarket(uint id, string market);
    
    struct MarketModel {
        uint id;
        string name;
    }

    function addMarket(string calldata marketName) external;

    function getMarket() external view returns(string memory);
}
