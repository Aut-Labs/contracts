//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./IAutID.sol";
import "./IDAOExpander.sol";
import "./membershipCheckers/IMembershipChecker.sol";

/// @title AutID
/// @notice
/// @dev
contract AutID is ERC721URIStorage, IAutID {
    using Counters for Counters.Counter;
    /// @notice
    Counters.Counter private _tokenIds;

    // Mapping from token ID to an active DAO that the AutID holder is a part of
    mapping(address => mapping(address => DAOMember)) private holderToDAOMembershipData;
    mapping(address => address[]) holderToDAOs;

    // Mapping from autIDOwner to token ID
    mapping(address => uint256) private _autIDByOwner;

    mapping(string => address) public autIDUsername;

    /// @notice
    mapping(uint256 => string) public override autIDToDiscordID;
    mapping(string => address) public override discordIDToAddress;

    constructor() ERC721("AutID", "AUT") {}

    /// @notice AutID holders can link their DiscordID to their AutID ID
    /// @dev links the discord ID to the AutID token ID passed.
    /// @param discordID the discord ID of the AutID holder
    function addDiscordIDToAutID(string calldata discordID) external override {
        uint256 autID = _autIDByOwner[msg.sender];

        autIDToDiscordID[autID] = discordID;
        discordIDToAddress[discordID] = msg.sender;

        emit DiscordIDConnectedToAutID();
    }

    /// @notice mints a new AutID NFT ID
    /// @dev each AutID holder can have only one AutID. It reverts if the AutID already exists. The user must be a part of the DAO passed.
    /// @param url the NFT metadata that holds username, avatar
    /// @param role the role that the user has selected within the specified DAO
    /// @param commitment the commitment value that the user has selected for this DAO
    /// @param daoExpander the address of the DAOExpender contract
    function mint(
        string memory username,
        string memory url,
        uint256 role,
        uint256 commitment,
        address daoExpander
    ) external override {
        require(role > 0 && role < 4, "Role must be between 1 and 3");
        require(
            commitment > 0 && commitment < 11,
            "AutID: Commitment should be between 1 and 10"
        );
        require(
            daoExpander != address(0),
            "AutID: Missing DAO Expander"
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
            IDAOExpander(daoExpander).isMemberOfOriginalDAO(
                msg.sender
            ) ||
                IDAOExpander(daoExpander).hasPassedOnboarding(
                    msg.sender
                ),
            "AutID: Not a member of this DAO!"
        );

        uint256 tokenId = _tokenIds.current();

        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, url);

        holderToDAOMembershipData[msg.sender][daoExpander] = DAOMember(
            daoExpander,
            role,
            commitment,
            true
        );
        holderToDAOs[msg.sender].push(daoExpander);

        _autIDByOwner[msg.sender] = tokenId;
        autIDUsername[username] = msg.sender;
        _tokenIds.increment();

        IDAOExpander(daoExpander).join(msg.sender);

        emit AutIDCreated(msg.sender, tokenId);
        emit DAOJoined(daoExpander, msg.sender);
    }

    /// @notice associates an AutID to a new DAO
    /// @dev The commitment of the user can't exceed 10. It fails if the user has already committed to other communities
    /// @param role the role that the user has selected within the specified DAO
    /// @param commitment the commitment value that the user has selected for this DAO
    /// @param daoExpander the address of the daoExpander contract
    function joinDAO(
        uint256 role,
        uint256 commitment,
        address daoExpander
    ) external override {
        require(role > 0 && role < 4, "Role must be between 1 and 3");
        require(
            commitment > 0 && commitment < 11,
            "AutID: Commitment should be between 1 and 10"
        );
        require(
            daoExpander != address(0),
            "AutID: Missing DAO Expander"
        );
        require(
            balanceOf(msg.sender) == 1,
            "AutID: There is no AutID registered for this address."
        );
        require(
            IDAOExpander(daoExpander).isMemberOfOriginalDAO(
                msg.sender
            ) ||
                IDAOExpander(daoExpander).hasPassedOnboarding(
                    msg.sender
                ),
            "AutID: Not a member of this DAO!"
        );
        address[] memory currentComs = holderToDAOs[msg.sender];
        for (uint256 index = 0; index < currentComs.length; index++) {
            require(
                currentComs[index] != daoExpander,
                "AutID: Already a member"
            );
        }

        holderToDAOMembershipData[msg.sender][daoExpander] = DAOMember(
            daoExpander,
            role,
            commitment,
            true
        );
        holderToDAOs[msg.sender].push(daoExpander);

        IDAOExpander(daoExpander).join(msg.sender);

        emit DAOJoined(daoExpander, msg.sender);
    }

    function withdraw(address daoExpander) external override {
        require(
            holderToDAOMembershipData[msg.sender][daoExpander].isActive,
            "AutID: Not a member"
        );
        holderToDAOMembershipData[msg.sender][daoExpander].isActive = false;
        holderToDAOMembershipData[msg.sender][daoExpander].commitment = 0;

        emit DAOWithdrown(daoExpander, msg.sender);
    }

    function editCommitment(address daoExpander, uint256 newCommitment)
        external
        override
    {
        require(
            holderToDAOMembershipData[msg.sender][daoExpander].isActive,
            "AutID: Not a member"
        );
        holderToDAOMembershipData[msg.sender][daoExpander]
            .commitment = newCommitment;

        emit CommitmentUpdated(daoExpander, msg.sender, newCommitment);
    }

    function setMetadataUri(string calldata metadataUri) public override {
        require(balanceOf(msg.sender) == 1, "AutID: Doesn't have an AutID.");
        uint tokenId = _autIDByOwner[msg.sender];
        _setTokenURI(tokenId, metadataUri);

        emit MetadataUriSet(tokenId, metadataUri);

    }

    /// @notice gets all communities the AutID holder is a member of
    /// @param autIDHolder the address of the AutID holder
    /// @return daos dao expander addresses that the aut holder is a part of
    function getHolderDAOs(address autIDHolder)
        external
        view
        override
        returns (address[] memory daos)
    {
        require(balanceOf(autIDHolder) == 1, "AutID: Doesn't have an AutID.");
        return holderToDAOs[autIDHolder];
    }

    function getMembershipData(address autIDHolder, address daoExpander)
        external
        view
        override
        returns (DAOMember memory)
    {
        return holderToDAOMembershipData[autIDHolder][daoExpander];
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
