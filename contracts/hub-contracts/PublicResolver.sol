// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./HubDomainsRegistry.sol";

contract PublicResolver {
    HubDomainsRegistry public hubDomainsRegistry;

    constructor(address _hubDomainsRegistry) {
        hubDomainsRegistry = HubDomainsRegistry(_hubDomainsRegistry);
    }

    function getDomain(string calldata domain) external view returns (address, string memory) {
        return hubDomainsRegistry.getDomain(domain);
    }
}
