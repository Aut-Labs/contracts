//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../interfaces/get/INovaMarket.sol";

/// @title DAOExpander
/// @notice The extension of each Nova that integrates Aut
/// @dev The extension of each Nova that integrates Aut
abstract contract NovaMarket is INovaMarket {
    event MarketSet(uint256);

    uint256 public override market;

    function _setMarket(uint256 _market) internal {
        require(_market > 0 && _market < 4, "invalid market");

        market = _market;
        emit MarketSet(_market);
    }

    uint256[10 - 1] private __gap;
}
