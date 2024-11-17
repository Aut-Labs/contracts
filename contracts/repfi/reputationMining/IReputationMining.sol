//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IReputationMining {
    function initialize(
        address initialOwner,
        address _repFiToken,
        address _cRepFiToken,
        address _circular,
        address _peerValueContract
    ) external;

    function currentPeriod() external view returns (uint256);

    function cleanupPeriod(uint256 periodId) external;

    function claimUtilityToken() external;

    function claim() external;

    function activateMining() external;

    function getTokensForPeriod(uint256 _period) external pure returns (uint256);

    function getClaimableUtilityTokenForPeriod(address _account, uint256 _period) external returns (uint256 amount);
}
