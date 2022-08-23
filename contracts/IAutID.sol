//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

/// @title IAutID
/// @notice The interface of the IAutID contract
/// @dev The contract is a non transferable ERC721 standard. It implements the logic of the role based membership within a DAO
interface IAutID is IERC721Upgradeable {
    event AutIDCreated(address owner, uint256 tokenID);
    event DAOJoined(address daoExpanderAddress, address member);
    event DAOWithdrown(address daoExpanderAddress, address member);
    event CommitmentUpdated(address daoExpanderAddress, address member, uint newCommitment);
    event DiscordIDConnectedToAutID();
    event MetadataUriSet(uint tokenId, string metadataUri);

    struct DAOMember {
        address daoExpanderAddress;
        uint256 role;
        uint256 commitment;
        bool isActive;
    }
    /// @notice mints a new AutID NFT ID
    /// @dev each AutID holder can have only one AutID. It reverts if the AutID already exists. The user must be a part of the DAO passed.
    /// @param url the NFT metadata that holds username, avatar
    /// @param role the role that the user has selected within the specified DAO
    /// @param commitment the commitment value that the user has selected for this DAO
    /// @param daoExpander the address of the daoExpander contract
    function mint(
        string memory username,
        string memory url,
        uint256 role,
        uint256 commitment,
        address daoExpander
    ) external;

    /// @notice associates a AutID to a new DAO
    /// @dev The commitment of the user can't exceed 10. It fails if the user has already committed to other DAOs
    /// @param role the role that the user has selected within the specified DAO
    /// @param commitment the commitment value that the user has selected for this DAO
    /// @param daoExpander the address of the daoExpander contract
    function joinDAO(
        uint256 role,
        uint256 commitment,
        address daoExpander
    ) external;

    /// @notice gets all communities the AutID holder is a member of
    /// @param autIDHolder the address of the AutID holder
    /// @return daos dao expander addresses that the aut holder is a part of
    function getHolderDAOs(address autIDHolder)
        external
        view
        returns (address[] memory daos);

    /// @notice returns NFT ID of the holder 
    /// @param autIDOwner the user address 
    /// @return the token ID of their NFT ID
    function getAutIDByOwner(address autIDOwner)
        external
        view
        returns (uint256);

    /// @notice AutID holders can link their DiscordID to their AutID ID
    /// @dev Returns a discord ID for the AutID token ID passed.
    /// @param tokenID the AutID token ID
    /// @return discord ID
    function autIDToDiscordID(uint256 tokenID)
        external
        view
        returns (string memory);

    /// @notice AutID holders can link their DiscordID to their AutID ID
    /// @dev links the discord ID to the AutID token ID passed.
    /// @param discordID the discord ID of the AutID holder
    function addDiscordIDToAutID(string calldata discordID) external;

    function getMembershipData(address autIDHolder, address daoExpander) external view returns(DAOMember memory);

    function withdraw(
        address daoExpander
    ) external;

    function editCommitment(
        address daoExpander,
        uint commitment
    ) external;

    function discordIDToAddress(
        string calldata discordID
    ) external view returns(address);

    function setMetadataUri(string calldata metadataUri) external;

}
