//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IDAOMarket.sol";

/// @title DAOExpander
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
abstract contract DAOMarket is IDAOMarket {

    uint _market;

    function setMarket(uint market)
        public
        virtual
        override
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
