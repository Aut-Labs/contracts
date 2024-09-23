// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPeerValue {
    struct PeerValueParams {
        uint256 participationScore;
        uint256 prestige;
        uint256 a_ring;
    }

    function getPeerValueParams(address account, uint256 period) external returns (PeerValueParams memory);

    function getPeerValue(address account, uint256 period) external returns (uint256);
}
