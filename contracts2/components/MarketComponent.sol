//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "../base/ComponentBase.sol";

/// @title Market component
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
contract MarketComponent is ComponentBase {
    event MarketSet(uint256);

    uint256 public market;

    function setMarket(uint256 _market) external novaCall {
        require(_market > 0 && _market < 4, "MarketComponent: invalid market");
        market = _market;
        emit MarketSet(market);
    }
}
