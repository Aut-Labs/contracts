// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IHubDomainsRegistry {
    event DomainRegistered(address indexed verifier, string domain, uint256 tokenId);

    function registerDomain(string calldata domain, string calldata metadataUri) external;
    function resolveDomain(string calldata domain) external view returns (address);
    function getDomainMetadata(string calldata domain) external view returns (string memory);
    function verifierOf(uint256 tokenId) external view returns (address verifier);
}
