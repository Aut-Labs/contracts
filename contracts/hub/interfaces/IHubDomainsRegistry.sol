// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct Domain {
    uint256 tokenId;
    string name;
    string uri;
}

interface IHubDomainsRegistry {
    /// @notice register an "X.hub" domain
    /// @dev must be called through the hub
    function registerDomain(string calldata _name, string calldata _uri) external;

    /// @notice get the Domain of a given hub
    function getDomain(address hub) external view returns (Domain memory);

    /// @notice Get the hub of a given "X.hub" name
    function getHubByName(string memory name) external view returns (address);
}
