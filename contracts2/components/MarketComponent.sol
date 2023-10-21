//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "../base/ComponentBase.sol";
import "../utils/Semver.sol";

/// @title Market component
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
contract MarketComponent is ComponentBase, Semver(0, 1, 0) {
    event MarketSet(uint256);

    uint256 public constant MARKETS_COUNT = 3;

    uint256 public market;

    function setMarket(uint256 market_) external novaCall {
        require(market_ != 0 && market_ <= MARKETS_COUNT, "MarketComponent: invalid market");
        market = market_;
        emit MarketSet(market_);
    }
}
