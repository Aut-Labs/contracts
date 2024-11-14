// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct Domain {
    uint256 tokenId;
    string name;
    string uri;
}

interface IHubDomainsRegistry {
    event DomainRegistered(address indexed hub, uint256 indexed tokenId, string name, string uri);

    function tokenId() external view returns (uint256);
    function hubRegistry() external view returns (address);

    /// @notice register an "X.hub" domain
    /// @dev must be called through the hub
    function registerDomain(string calldata _name, string calldata _uri, address _owner) external;

    /// @notice Return the Domain data relative to a hub
    function domains(address hub) external view returns (Domain memory);

    /// @notice return the address of a hub given its' name
    function nameToHub(string memory _name) external view returns (address hub);

    /// @notice return the address of a hub given its' tokenId
    function tokenIdToHub(uint256 _tokenId) external view returns (address hub);
}
