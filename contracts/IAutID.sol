//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/// @title IAutID
/// @notice The interface of the IAutID contract
/// @dev The contract is a non transferable ERC721 standard. It implements the logic of the role based membership within a community
interface IAutID is IERC721 {
    event AutIDCreated(address owner, uint256 tokenID);
    event CommunityJoined(address communityAddress, address member);
    event CommunityWithdrown(address communityAddress, address member);
    event CommitmentUpdated(address communityAddress, address member, uint newCommitment);
    event DiscordIDConnectedToAutID();
    event MetadataUriSet(uint tokenId, string metadataUri);

    struct CommunityMember {
        address communityExtension;
        uint256 role;
        uint256 commitment;
        bool isActive;
    }
    /// @notice mints a new AutID NFT ID
    /// @dev each SW holder can have only one AutID. It reverts if the AutID already exists. The user must be a part of the community passed.
    /// @param url the NFT metadata that holds username, avatar
    /// @param role the role that the user has selected within the specified community
    /// @param commitment the commitment value that the user has selected for this community
    /// @param communityExtension the address of the communityExtension contract
    function mint(
        string memory username,
        string memory url,
        uint256 role,
        uint256 commitment,
        address communityExtension
    ) external;

    /// @notice associates a AutID to a new Community
    /// @dev The commitment of the user can't exceed 10. It fails if the user has already committed to other communities
    /// @param role the role that the user has selected within the specified community
    /// @param commitment the commitment value that the user has selected for this community
    /// @param communityExtension the address of the communityExtension contract
    function joinCommunity(
        uint256 role,
        uint256 commitment,
        address communityExtension
    ) external;

    /// @notice gets all communities the AutID holder is a member of 
    /// @param autIDHolder the address of the AutID holder
    /// @return communities struct with community data for all communities that the user is a part of 
    function getCommunities(address autIDHolder)
        external
        view
        returns (address[] memory communities);

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

    function getCommunityData(address autIDHolder, address communityExtension) external view returns(CommunityMember memory);

    function withdraw(
        address communityExtension
    ) external;

    function editCommitment(
        address communityExtension,
        uint commitment
    ) external;

    function discordIDToAddress(
        string calldata discordID
    ) external view returns(address);

    function setMetadataUri(string calldata metadataUri) external;

}
