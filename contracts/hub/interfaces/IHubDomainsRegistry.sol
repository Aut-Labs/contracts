// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IHubDomainsRegistry {
    /// @notice register an "X.hub" domain
    /// @dev must be called through the hub
    function registerDomain(string calldata domain, address hubAddress, string calldata metadataUri) external;

    /// @notice get hub and uri associated to the "X.hub" domain
    function getDomain(string calldata domain) external view returns (address, string memory);
    function verifierOf(uint256 tokenId) external view returns (address verifier);
}
