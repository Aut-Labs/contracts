//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "../base/ComponentBase.sol";

/// @title Market component
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
contract MarketComponent is ComponentBase {
    event MarketSet(uint256);

    uint256 internal _market;

    function setMarket(uint256 market) external novaCall {
        require(market > 0 && market < 4, "MarketComponent: invalid market");
        _market = market;
        emit MarketSet(market);
    }

    function getMarket() external view returns (uint256) {
        return _market;
    }
}
