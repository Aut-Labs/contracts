// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IHubDomainsRegistry.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import {
    ERC2771ContextUpgradeable,
    ContextUpgradeable
} from "@openzeppelin/contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol";

contract HubDomainsRegistry is IHubDomainsRegistry, Ownable {
    struct Domain {
        string name;
        address verifier;
        string metadataUri;
    }

    mapping(string => Domain) private domains;
    mapping(address => string[]) private verifierToDomains;
    mapping(uint256 => string) private tokenIdToDomain;
    uint256 private tokenIdCounter;
    address private permittedContract;

    event DomainRegistered(address indexed verifier, string domain, uint256 tokenId);

    constructor(address _permittedContract) Ownable(msg.sender) {
        require(_permittedContract != address(0), "Permitted contract address cannot be zero");
        tokenIdCounter = 0;
        permittedContract = _permittedContract;
    }

    modifier onlyPermittedContract() {
        require(msg.sender == permittedContract, "Caller is not the permitted contract");
        _;
    }

    function registerDomain(
        string calldata domain,
        string calldata metadataUri
    ) external override(IHubDomainsRegistry) onlyPermittedContract {
        require(domains[domain].verifier == address(0), "Domain already registered");
        require(_isValidDomain(domain), "Invalid domain format");

        tokenIdCounter++;
        domains[domain] = Domain(domain, msg.sender, metadataUri);
        verifierToDomains[msg.sender].push(domain);
        tokenIdToDomain[tokenIdCounter] = domain;

        emit DomainRegistered(msg.sender, domain, tokenIdCounter);
    }

    function getDomain(string calldata domain) external view returns (address, string memory) {
        return (domains[domain].verifier, domains[domain].metadataUri);
    }

    function verifierOf(uint256 tokenId) external view returns (address verifier) {
        return domains[tokenIdToDomain[tokenId]].verifier;
    }

    function _isValidDomain(string memory domain) internal pure returns (bool) {
        bytes memory b = bytes(domain);
        if (b.length == 0 || b.length > 20) return false; // Adjust length as needed
        if (!(_endsWithHub(domain))) return false; // Ends with ".hub"
        for (uint i; i < b.length - 4; i++) {
            // Skip ".hub"
            if (
                !(b[i] >= 0x30 && b[i] <= 0x39) && // 0-9
                !(b[i] >= 0x41 && b[i] <= 0x5A) && // A-Z
                !(b[i] >= 0x61 && b[i] <= 0x7A)
            ) {
                // a-z
                return false;
            }
        }
        return true;
    }

    function _endsWithHub(string memory domain) internal pure returns (bool) {
        bytes memory b = bytes(domain);
        return
            b.length >= 4 &&
            b[b.length - 1] == "b" &&
            b[b.length - 2] == "u" &&
            b[b.length - 3] == "h" &&
            b[b.length - 4] == ".";
    }
}
