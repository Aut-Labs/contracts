// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IHubDomainsRegistry {
    function registerDomain(string calldata domain, string calldata metadataUri) external;
    function resolveDomain(string calldata domain) external view returns (address);
    function getDomainMetadata(string calldata domain) external view returns (string memory);
    function ownerOf(uint256 tokenId) external view returns (address owner);
}
