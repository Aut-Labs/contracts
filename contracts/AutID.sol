//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./CommunityExtension.sol";
import "./IAutID.sol";
import "./membershipCheckers/IMembershipChecker.sol";

/// @title AutID
/// @notice
/// @dev
contract AutID is ERC721URIStorage, IAutID {
    using Counters for Counters.Counter;
    /// @notice
    Counters.Counter private _tokenIds;

    // Mapping from token ID to active community that the SW is part of
    mapping(address => mapping(address => CommunityMember))
        private _communityData;
    mapping(address => address[]) _communities;

    // Mapping from autIDOwner to token ID
    mapping(address => uint256) private _autIDByOwner;

    mapping(string => address) public autIDUsername;

    /// @notice
    mapping(uint256 => string) public override autIDToDiscordID;
    mapping(string => address) public override discordIDToAddress;

    constructor() ERC721("AutID", "AUT") {}

    /// @notice SW holders can link their DiscordID to their SW ID
    /// @dev links the discord ID to the SW token ID passed.
    /// @param discordID the discord ID of the sw holder
    function addDiscordIDToAutID(string calldata discordID) external override {
        uint256 autID = _autIDByOwner[msg.sender];

        autIDToDiscordID[autID] = discordID;
        discordIDToAddress[discordID] = msg.sender;

        emit DiscordIDConnectedToAutID();
    }

    /// @notice mints a new SW NFT ID
    /// @dev each SW holder can have only one SW. It reverts if the SW already exists. The user must be a part of the community passed.
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
    ) external override {
        require(role > 0 && role < 4, "Role must be between 1 and 3");
        require(
            commitment > 0 && commitment < 11,
            "AutID: Commitment should be between 1 and 10"
        );
        require(
            communityExtension != address(0),
            "AutID: Missing community extension"
        );
        require(
            balanceOf(msg.sender) == 0,
            "AutID: There is AutID already registered for this address."
        );
        require(
            autIDUsername[username] == address(0),
            "AutID: Username already taken!"
        );

        require(
            CommunityExtension(communityExtension).isMemberOfOriginalDAO(
                msg.sender
            ) ||
                CommunityExtension(communityExtension).hasPassedOnboarding(
                    msg.sender
                ),
            "AutID: Not a member of this DAO!"
        );

        uint256 tokenId = _tokenIds.current();

        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, url);

        _communityData[msg.sender][communityExtension] = CommunityMember(
            communityExtension,
            role,
            commitment,
            true
        );
        _communities[msg.sender].push(communityExtension);

        _autIDByOwner[msg.sender] = tokenId;
        autIDUsername[username] = msg.sender;
        _tokenIds.increment();

        CommunityExtension(communityExtension).join(msg.sender);

        emit AutIDCreated(msg.sender, tokenId);
        emit CommunityJoined(communityExtension, msg.sender);
    }

    /// @notice associates a SW to a new Community
    /// @dev The commitment of the user can't exceed 10. It fails if the user has already committed to other communities
    /// @param role the role that the user has selected within the specified community
    /// @param commitment the commitment value that the user has selected for this community
    /// @param communityExtension the address of the communityExtension contract
    function joinCommunity(
        uint256 role,
        uint256 commitment,
        address communityExtension
    ) external override {
        require(role > 0 && role < 4, "Role must be between 1 and 3");
        require(
            commitment > 0 && commitment < 11,
            "AutID: Commitment should be between 1 and 10"
        );
        require(
            communityExtension != address(0),
            "AutID: Missing community extension"
        );
        require(
            balanceOf(msg.sender) == 1,
            "AutID: There is no AutID registered for this address."
        );
        require(
            CommunityExtension(communityExtension).isMemberOfOriginalDAO(
                msg.sender
            ) ||
                CommunityExtension(communityExtension).hasPassedOnboarding(
                    msg.sender
                ),
            "AutID: Not a member of this DAO!"
        );
        address[] memory currentComs = _communities[msg.sender];
        for (uint256 index = 0; index < currentComs.length; index++) {
            require(
                currentComs[index] != communityExtension,
                "AutID: Already a member"
            );
        }

        _communityData[msg.sender][communityExtension] = CommunityMember(
            communityExtension,
            role,
            commitment,
            true
        );
        _communities[msg.sender].push(communityExtension);

        CommunityExtension(communityExtension).join(msg.sender);

        emit CommunityJoined(communityExtension, msg.sender);
    }

    function withdraw(address communityExtension) external override {
        require(
            _communityData[msg.sender][communityExtension].isActive,
            "AutID: Not a member"
        );
        _communityData[msg.sender][communityExtension].isActive = false;
        _communityData[msg.sender][communityExtension].commitment = 0;

        emit CommunityWithdrown(communityExtension, msg.sender);
    }

    function editCommitment(address communityExtension, uint256 newCommitment)
        external
        override
    {
        require(
            _communityData[msg.sender][communityExtension].isActive,
            "AutID: Not a member"
        );
        _communityData[msg.sender][communityExtension]
            .commitment = newCommitment;

        emit CommitmentUpdated(communityExtension, msg.sender, newCommitment);
    }

    function setMetadataUri(string calldata metadataUri) public override {
        require(balanceOf(msg.sender) == 1, "AutID: Doesn't have a SW.");
        uint tokenId = _autIDByOwner[msg.sender];
        _setTokenURI(tokenId, metadataUri);

        emit MetadataUriSet(tokenId, metadataUri);

    }

    /// @notice gets all communities the SW holder is a member of
    /// @param autIDHolder the address of the SW holder
    /// @return communities struct with community data for all communities that the user is a part of
    function getCommunities(address autIDHolder)
        external
        view
        override
        returns (address[] memory communities)
    {
        require(balanceOf(autIDHolder) == 1, "AutID: Doesn't have a SW.");
        return _communities[autIDHolder];
    }

    function getCommunityData(address autIDHolder, address communityExtension)
        external
        view
        override
        returns (CommunityMember memory)
    {
        return _communityData[autIDHolder][communityExtension];
    }

    /// @notice returns NFT ID of the holder
    /// @param autIDOwner the user address
    /// @return the token ID of their NFT ID
    function getAutIDByOwner(address autIDOwner)
        external
        view
        override
        returns (uint256)
    {
        require(
            balanceOf(autIDOwner) == 1,
            "AutID: The AutID owner is invalid."
        );
        return _autIDByOwner[autIDOwner];
    }

    /// ERC 721 s

    /// @notice ERC721 _transfer() Disabled
    /// @dev _transfer() has been n
    /// @dev reverts on transferFrom() and safeTransferFrom()
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        require(false, "AutID: AutID transfer disabled");
    }

    /// @notice ERC721 _safeTransfer() Disabled
    /// @dev _safeTransfer() has been n
    /// @dev reverts on transferFrom() and safeTransferFrom()
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal override {
        require(false, "AutID: AutID transfer disabled");
    }
}
