//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IReputationMining {
    function initialize(
        address initialOwner,
        address _autToken,
        address _cAutToken,
        address _circular,
        address _peerValueContract,
        address _autId
    ) external;

    function currentPeriod() external view returns (uint256);

    function cleanupPeriod(uint256 periodId) external;

    function claimCToken() external;

    function claimPeriod(uint256 period) external;

    function claimAllPeriods() external;

    function activateMining() external;

    function getClaimableCTokenForPeriod(address _account, uint256 _period) external returns (uint256 amount);
}
