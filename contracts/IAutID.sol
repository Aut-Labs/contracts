//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

/// @title IAutID
/// @notice The interface of the IAutID contract
/// @dev The contract is a non transferable ERC721 standard. It implements the logic of the role based membership within a Nova
interface IAutID is IERC721Upgradeable {
    event AutIDCreated(address owner, uint256 tokenID);
    event NovaJoined(address NovaExpanderAddress, address member);
    event NovaWithdrawn(address NovaExpanderAddress, address member);
    event CommitmentUpdated(address NovaExpanderAddress, address member, uint256 newCommitment);
    event DiscordIDConnectedToAutID();
    event MetadataUriSet(uint256 tokenId, string metadataUri);

    struct NovaMember {
        address NovaExpanderAddress;
        uint256 role;
        uint256 commitment;
        bool isActive;
    }

    /// @notice mints a new AutID NFT ID
    /// @dev each AutID holder can have only one AutID. It reverts if the AutID already exists. The user must be a part of the Nova passed.
    /// @param url the NFT metadata that holds username, avatar
    /// @param role the role that the user has selected within the specified Nova
    /// @param commitment the commitment value that the user has selected for this Nova
    /// @param NovaExpander the address of the NovaExpander contract
    function mint(string memory username, string memory url, uint256 role, uint256 commitment, address NovaExpander)
        external;

    /// @notice associates a AutID to a new Nova
    /// @dev The commitment of the user can't exceed 10. It fails if the user has already committed to other Novas
    /// @param role the role that the user has selected within the specified Nova
    /// @param commitment the commitment value that the user has selected for this Nova
    /// @param NovaExpander the address of the NovaExpander contract
    function joinNova(uint256 role, uint256 commitment, address NovaExpander) external;

    /// @notice gets all communities the AutID holder is a member of
    /// @param autIDHolder the address of the AutID holder
    /// @return Novas Nova expander addresses that the aut holder is a part of
    function getHolderNovae(address autIDHolder) external view returns (address[] memory Novas);

    /// @notice returns NFT ID of the holder
    /// @param autIDOwner the user address
    /// @return the token ID of their NFT ID
    function getAutIDByOwner(address autIDOwner) external view returns (uint256);

    /// @notice AutID holders can link their DiscordID to their AutID ID
    /// @dev Returns a discord ID for the AutID token ID passed.
    /// @param tokenID the AutID token ID
    /// @return discord ID
    function autIDToDiscordID(uint256 tokenID) external view returns (string memory);

    /// @notice AutID holders can link their DiscordID to their AutID ID
    /// @dev links the discord ID to the AutID token ID passed.
    /// @param discordID the discord ID of the AutID holder
    function addDiscordIDToAutID(string calldata discordID) external;

    function getMembershipData(address autIDHolder, address NovaExpander) external view returns (NovaMember memory);

    function getTotalCommitment(address autIDHolder) external view returns (uint256);

    function withdraw(address NovaExpander) external;

    function editCommitment(address NovaExpander, uint256 commitment) external;

    function discordIDToAddress(string calldata discordID) external view returns (address);

    function setMetadataUri(string calldata metadataUri) external;

    function getAutIDHolderByUsername(string memory username) external view returns (address);
    function getNextTokenID() external view returns (uint256);

    function getAllActiveMembers(address nova_) external view returns (address[] memory);

    /// @notice returns commitment levels for agents in a Nova
    /// @param agents address of agents
    /// @param Nova_ commitment target
    function getCommitmentsOfFor(address[] memory agents, address Nova_)
        external
        view
        returns (uint256[] memory commitments);
}
