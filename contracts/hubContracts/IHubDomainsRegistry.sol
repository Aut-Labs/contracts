// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IHubDomainsRegistry {
    function registerDomain(string calldata domain, address novaAddress, string calldata metadataUri) external;
    function getDomain(string calldata domain) external view returns (address, string memory);
    function verifierOf(uint256 tokenId) external view returns (address verifier);
}
