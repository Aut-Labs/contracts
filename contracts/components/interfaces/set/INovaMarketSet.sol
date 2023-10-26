//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title INova
/// @notice The interface for the extension of each DAO that integrates AutID
interface INovaMarketSet {
    function setMarket(uint256 market) external;
}
