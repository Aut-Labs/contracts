// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IHubDomains.sol";
import "./IHubDomainsRegistry.sol";

contract HubDomainsRegistry is IHubDomains, IHubDomainsRegistry, Ownable {
    struct Domain {
        string name;
        address owner;
        string metadataUri;
    }

    mapping(string => Domain) private domains;
    mapping(address => string[]) private ownerToDomains;
    mapping(uint256 => string) private tokenIdToDomain;
    uint256 private tokenIdCounter;

    event DomainRegistered(address indexed owner, string domain, uint256 tokenId);

    function registerDomain(string calldata domain, string calldata metadataUri) external override(IHubDomains, IHubDomainsRegistry) {
        require(domains[domain].owner == address(0), "Domain already registered");
        require(_isValidDomain(domain), "Invalid domain format");

        tokenIdCounter++;
        domains[domain] = Domain(domain, msg.sender, metadataUri);
        ownerToDomains[msg.sender].push(domain);
        tokenIdToDomain[tokenIdCounter] = domain;

        emit DomainRegistered(msg.sender, domain, tokenIdCounter);
    }

    function resolveDomain(string calldata domain) external view override(IHubDomains, IHubDomainsRegistry) returns (address) {
        return domains[domain].owner;
    }

    function getDomainMetadata(string calldata domain) external view override(IHubDomains, IHubDomainsRegistry) returns (string memory) {
        return domains[domain].metadataUri;
    }

    function ownerOf(uint256 tokenId) external view override(IHubDomains, IHubDomainsRegistry) returns (address owner) {
        return domains[tokenIdToDomain[tokenId]].owner;
    }

    function _isValidDomain(string memory domain) internal pure returns (bool) {
        bytes memory b = bytes(domain);
        if (b.length == 0 || b.length > 20) return false; // Adjust length as needed
        if (!(_endsWithHub(domain))) return false; // Ends with ".hub"
        for (uint i; i < b.length - 4; i++) { // Skip ".hub"
            if (!(b[i] >= 0x30 && b[i] <= 0x39) && // 0-9
                !(b[i] >= 0x41 && b[i] <= 0x5A) && // A-Z
                !(b[i] >= 0x61 && b[i] <= 0x7A)) { // a-z
                return false;
            }
        }
        return true;
    }

    function _endsWithHub(string memory domain) internal pure returns (bool) {
        bytes memory b = bytes(domain);
        return b.length >= 4 &&
               b[b.length - 1] == 'b' &&
               b[b.length - 2] == 'u' &&
               b[b.length - 3] == 'h' &&
               b[b.length - 4] == '.';
    }
}
