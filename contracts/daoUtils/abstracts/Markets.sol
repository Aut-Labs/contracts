//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IMarket.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title DAOExpander
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
abstract contract Market is IMarket, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _marketIds;

    mapping(uint256 => MarketModel) _markets;

    function addMarket(string calldata marketName)
        public
        virtual
        override
        onlyOwner
    {
        _marketIds.increment();
        _markets[_marketIds.current()] = MarketModel(_marketIds.current(), marketName);
        emit AddedMarket(_marketIds.current(), marketName);
    }

    function getMarket(uint _marketId) external view returns (MarketModel memory) {
        return _markets[_marketId];
    }
}
