// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./interfaces/IHubDomainsRegistry.sol";
import "./interfaces/IHubRegistry.sol";

contract HubDomainsRegistry is IHubDomainsRegistry, OwnableUpgradeable {
    struct Domain {
        string name;
        address hubAddress;
        address verifier;
        string metadataUri;
    }

    mapping(string => Domain) private domains;
    mapping(address => string[]) private hubAddressToDomains;
    mapping(uint256 => string) private tokenIdToDomain;
    uint256 private tokenIdCounter;
    address private hubRegistry;

    event DomainRegistered(
        address indexed hubAddress,
        address verifier,
        string domain,
        uint256 tokenId,
        string metadataUri
    );

    constructor() {
        _disableInitializers();
    }

    function initialize(address _hubRegistry) external initializer {
        __Ownable_init(msg.sender);
        hubRegistry = _hubRegistry;
    }

    modifier onlyFromHub() {
        require(IHubRegistry(hubRegistry).checkHub(msg.sender));
        _;
    }

    function registerDomain(
        string calldata domain,
        address hubAddress,
        string calldata metadataUri
    ) external override(IHubDomainsRegistry) onlyFromHub {
        require(domains[domain].hubAddress == address(0), "Domain already registered");
        require(hubAddressToDomains[hubAddress].length == 0, "Domain already registered");
        require(_isValidDomain(domain), "Invalid domain format");

        tokenIdCounter++;
        domains[domain] = Domain(domain, hubAddress, msg.sender, metadataUri);
        hubAddressToDomains[hubAddress].push(domain);
        tokenIdToDomain[tokenIdCounter] = domain;

        emit DomainRegistered(hubAddress, msg.sender, domain, tokenIdCounter, metadataUri);
    }

    function getDomain(string calldata domain) external view returns (address, string memory) {
        return (domains[domain].hubAddress, domains[domain].metadataUri);
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
