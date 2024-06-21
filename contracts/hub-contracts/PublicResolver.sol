// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./HubDomainsRegistry.sol";

contract PublicResolver {
    HubDomainsRegistry public hubDomainsRegistry;

    constructor(address _hubDomainsRegistry) {
        hubDomainsRegistry = HubDomainsRegistry(_hubDomainsRegistry);
    }

    function resolveDomain(string calldata domain) external view returns (address) {
        return hubDomainsRegistry.resolveDomain(domain);
    }

    function getDomainMetadata(string calldata domain) external view returns (string memory) {
        return hubDomainsRegistry.getDomainMetadata(domain);
    }
}
