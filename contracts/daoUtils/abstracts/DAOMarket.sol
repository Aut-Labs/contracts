//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/get/IDAOMarket.sol";

/// @title DAOExpander
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
abstract contract DAOMarket is IDAOMarket {
    event MarketSet();

    uint _market;

    function _setMarket(uint market)
        internal
    {
         require(
            market > 0 && market < 4,
            "Market invalid"
        );

        _market = market;
        emit MarketSet();
    }

    function getMarket() public override view returns(uint) {
        return _market;
    }
}
