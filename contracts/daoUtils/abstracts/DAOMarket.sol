//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../interfaces/get/IDAOMarket.sol";

/// @title DAOExpander
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
abstract contract DAOMarket is IDAOMarket {
    event MarketSet();

    uint256 public override market;

    function _setMarket(uint256 _market) internal {
        require(_market > 0 && _market < 4, "invalid market");

        market = _market;
        emit MarketSet();
    }
}
