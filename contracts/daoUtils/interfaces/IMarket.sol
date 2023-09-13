//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title IMarket
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
interface IMarket {
    event AddedMarket(uint256 id, string market);

    struct MarketModel {
        uint256 id;
        string metadata;
    }

    function addMarket(string calldata metadata) external;

    function getMarket() external view returns (string memory);
}
