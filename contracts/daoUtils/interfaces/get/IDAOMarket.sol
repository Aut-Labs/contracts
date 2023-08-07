//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/// @title IDAOMarket
/// @notice The interface for the extension of each DAO that integrates AutID
interface IDAOMarket {
    function market() external view returns(uint market);
}
