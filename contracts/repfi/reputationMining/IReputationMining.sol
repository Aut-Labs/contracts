//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IReputationMining {
    function initialize(
        address initialOwner,
        address _repFiToken,
        address _pRepFiToken,
        address _circular,
        address _peerValueContract
    ) external;

    function updatePeriod() external;

    function claimUtilityToken() external;

    function claim() external;

    function getTokensForPeriod(uint256 _period) external pure returns (uint256);
}
