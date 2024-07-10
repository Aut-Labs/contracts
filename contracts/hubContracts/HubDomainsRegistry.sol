// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IHubDomainsRegistry.sol";

contract HubDomainsRegistry is IHubDomainsRegistry, Ownable {
    struct Domain {
        string name;
        address novaAddress;
        address verifier;
        string metadataUri;
    }

    mapping(string => Domain) private domains;
    mapping(address => string[]) private novaAddressToDomains;
    mapping(uint256 => string) private tokenIdToDomain;
    uint256 private tokenIdCounter;
    address private permittedContract;

    event DomainRegistered(address indexed novaAddress, address verifier, string domain, uint256 tokenId, string metadataUri);

    constructor() Ownable(msg.sender) {
        tokenIdCounter = 0;
    }

    modifier onlyPermittedContract() {
        require(msg.sender == permittedContract, "Caller is not the permitted contract");
        _;
    }

    function registerDomain(
        string calldata domain,
        address novaAddress,
        string calldata metadataUri
    ) external override(IHubDomainsRegistry) onlyPermittedContract {
        require(domains[domain].novaAddress == address(0), "Domain already registered");
        require(novaAddressToDomains[novaAddress].length == 0, "Domain already registered");
        require(_isValidDomain(domain), "Invalid domain format");

        tokenIdCounter++;
        domains[domain] = Domain(domain, novaAddress, msg.sender, metadataUri);
        novaAddressToDomains[novaAddress].push(domain);
        tokenIdToDomain[tokenIdCounter] = domain;

        emit DomainRegistered(novaAddress, msg.sender, domain, tokenIdCounter, metadataUri);
    }

    function getDomain(string calldata domain) external view returns (address, string memory) {
        return (domains[domain].novaAddress, domains[domain].metadataUri);
    }

    function setPermittedContract(address _permittedContract) external onlyOwner {
        require(_permittedContract != address(0), "Permitted contract address cannot be zero");
        permittedContract = _permittedContract;
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
