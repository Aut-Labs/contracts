// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAutID {
    event RecordCreated(uint256 tokenId, address account, string username, string uri);
    event NovaJoined(address account, uint256 role, uint256 commitment, address nova);
    event NovaRegistrySet(address);
    event LocalReputationSet(address);
    event TokenMetadataUpdated(uint256 tokenId, address account, string uri);

    /// @notice Retrieve NovaRegistry contract address
    function novaRegistry() external view returns(address);

    /// @notice Retrieve LocalReputation contract address
    function localReputation() external view returns(address);

    /// @notice Retrieve AutID NFT tokenId for the given holder username
    /// @param usernameBytes32 AutID NFT holder username (converted to `bytes32`)
    /// @return tokenId AutID NFT tokenId
    function tokenIdForUsername(bytes32 usernameBytes32) external view returns(uint256 tokenId);

    /// @notice Retrieve AutID NFT tokenId for the given holder address
    /// @param account AutID NFT holder address
    /// @return tokenId AutID NFT tokenId
    function tokenIdForAccount(address account) external view returns(uint256 tokenId);

    /// @notice Set NovaRegistry contract address
    function setNovaRegistry(address) external;

    /// @notice Set LocalReputation contract address
    function setLocalReputation(address) external;

    /// @notice Update a metadata URI string associated with the sender's AutID NFT
    function updateTokenURI(string memory uri) external;

    /// @notice Mint an AutID NFT and join a Nova community
    /// @param role Role to join the Nova
    /// @param commitment Commitment to join the Nova
    /// @param nova Address of the Nova to join
    /// @param username_ Username associated with the new AutID NFT
    /// @param optionalURI Metadata URI string associated with the new AutID NFT
    function mint(
        uint256 role,
        uint256 commitment,
        address nova,
        string memory username_,
        string memory optionalURI
    ) external;

    /// @notice Mint an AutID NFT and join a Nova community (alias to `mint`)
    /// @param role Role to join the Nova
    /// @param commitment Commitment to join the Nova
    /// @param nova Address of the Nova to join
    /// @param username_ Username associated with the new AutID NFT
    /// @param optionalURI Metadata URI string associated with the new AutID NFT
    function createRecordAndJoinNova(
        uint256 role,
        uint256 commitment,
        address nova,
        string memory username_,
        string memory optionalURI
    ) external;

    /// @notice Join a Nova community as an AutID NFT holder
    /// @param role Role to join the Nova
    /// @param commitment Commitment to join the Nova
    /// @param nova Address of the Nova to join
    function joinNova(uint256 role, uint256 commitment, address nova) external;
}
