//SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@opengsn/contracts/src/ERC2771Recipient.sol";

import "./IAutID.sol";
import "./daoUtils/interfaces/get/IDAOCommitment.sol";
import "./daoUtils/interfaces/set/IDAOMembershipSet.sol";
import "./daoUtils/interfaces/get/IDAOMembership.sol";
import "./membershipCheckers/IMembershipChecker.sol";

/// @title AutID
/// @notice
/// @dev
contract AutID is ERC2771Recipient, ERC721URIStorageUpgradeable, IAutID {
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

    function initialize(address trustedForwarder) public initializer {
        __ERC721_init("AutID", "AUT");
        _setTrustedForwarder(trustedForwarder);
    }

    /// @notice AutID holders can link their DiscordID to their AutID ID
    /// @dev links the discord ID to the AutID token ID passed.
    /// @param discordID the discord ID of the AutID holder
    function addDiscordIDToAutID(string calldata discordID) external override {
        uint256 autID = _autIDByOwner[_msgSender()];

        autIDToDiscordID[autID] = discordID;
        discordIDToAddress[discordID] = _msgSender();

        emit DiscordIDConnectedToAutID();
    }

    /// @notice mints a new AutID NFT ID
    /// @dev each AutID holder can have only one AutID. It reverts if the AutID already exists. The user must be a part of the DAO passed.
    /// @param url the NFT metadata that holds username, avatar
    /// @param role the role that the user has selected within the specified DAO
    /// @param commitment the commitment value that the user has selected for this DAO
    /// @param daoAddress the address of the DAOExpender contract
    function mint(string memory username, string memory url, uint256 role, uint256 commitment, address daoAddress)
        external
        override
    {
        require(bytes(username).length < 17, "Username must be max 16 characters");
        require(role > 0 && role < 4, "Role must be between 1 and 3");
        require(commitment > 0 && commitment < 11, "AutID: Commitment should be between 1 and 10");
        require(daoAddress != address(0), "AutID: Missing DAO");
        require(balanceOf(_msgSender()) == 0, "AutID: There is AutID already registered for this address.");
        require(autIDUsername[username] == address(0), "AutID: Username already taken!");

        require(IDAOMembership(daoAddress).canJoin(_msgSender(), role), "AutID: Not a member of this DAO!");

        string memory lowerCase = _toLower(username);
        uint256 tokenId = _tokenIds.current();

        _safeMint(_msgSender(), tokenId);
        _setTokenURI(tokenId, url);

        holderToDAOMembershipData[_msgSender()][daoAddress] = DAOMember(daoAddress, role, commitment, true);
        holderToDAOs[_msgSender()].push(daoAddress);

        _autIDByOwner[_msgSender()] = tokenId;
        autIDUsername[lowerCase] = _msgSender();
        _tokenIds.increment();

        IDAOMembershipSet(daoAddress).join(_msgSender(), role);

        emit AutIDCreated(_msgSender(), tokenId);
        emit DAOJoined(daoAddress, _msgSender());
    }

    /// @notice associates an AutID to a new DAO
    /// @dev The commitment of the user can't exceed 10. It fails if the user has already committed to other communities
    /// @param role the role that the user has selected within the specified DAO
    /// @param commitment the commitment value that the user has selected for this DAO
    /// @param daoAddress the address of the daoAddress contract
    function joinDAO(uint256 role, uint256 commitment, address daoAddress) external override {
        require(role > 0 && role < 4, "Role must be between 1 and 3");
        require(commitment > 0 && commitment < 11, "AutID: Commitment should be between 1 and 10");
        require(daoAddress != address(0), "AutID: Missing DAO");
        require(balanceOf(_msgSender()) == 1, "AutID: There is no AutID registered for this address.");

        address[] memory currentComs = holderToDAOs[_msgSender()];
        for (uint256 index = 0; index < currentComs.length; index++) {
            require(currentComs[index] != daoAddress, "AutID: Already a member");
        }

        require(
            commitment >= IDAOCommitment(daoAddress).getCommitment(), "Commitment lower than the DAOs min commitment"
        );

        require(IDAOMembership(daoAddress).canJoin(_msgSender(), role), "AutID: Not a member of this DAO!");

        holderToDAOMembershipData[_msgSender()][daoAddress] = DAOMember(daoAddress, role, commitment, true);
        holderToDAOs[_msgSender()].push(daoAddress);

        IDAOMembershipSet(daoAddress).join(_msgSender(), role);

        emit DAOJoined(daoAddress, _msgSender());
    }

    function withdraw(address daoAddress) external override {
        require(holderToDAOMembershipData[_msgSender()][daoAddress].isActive, "AutID: Not a member");
        holderToDAOMembershipData[_msgSender()][daoAddress].isActive = false;
        holderToDAOMembershipData[_msgSender()][daoAddress].commitment = 0;

        emit DAOWithdrown(daoAddress, _msgSender());
    }

    function editCommitment(address daoAddress, uint256 newCommitment) external override {
        require(holderToDAOMembershipData[_msgSender()][daoAddress].isActive, "AutID: Not a member");

        require(newCommitment > 0 && newCommitment < 11, "AutID: Commitment should be between 1 and 10");

        require(
            newCommitment >= IDAOCommitment(daoAddress).getCommitment(), "Commitment lower than the DAOs min commitment"
        );

        holderToDAOMembershipData[_msgSender()][daoAddress].commitment = newCommitment;

        emit CommitmentUpdated(daoAddress, _msgSender(), newCommitment);
    }

    function setMetadataUri(string calldata metadataUri) public override {
        require(balanceOf(_msgSender()) == 1, "AutID: There is no AutID registered for this address.");
        uint256 tokenId = _autIDByOwner[_msgSender()];
        _setTokenURI(tokenId, metadataUri);

        emit MetadataUriSet(tokenId, metadataUri);
    }

    /// @notice gets all communities the AutID holder is a member of
    /// @param autIDHolder the address of the AutID holder
    /// @return daos dao expander addresses that the aut holder is a part of
    function getHolderDAOs(address autIDHolder) external view override returns (address[] memory daos) {
        require(balanceOf(autIDHolder) == 1, "AutID: There is no AutID registered for this address.");
        return holderToDAOs[autIDHolder];
    }

    function getMembershipData(address autIDHolder, address daoAddress)
        external
        view
        override
        returns (DAOMember memory)
    {
        return holderToDAOMembershipData[autIDHolder][daoAddress];
    }

    /// @notice returns NFT ID of the holder
    /// @param autIDOwner the user address
    /// @return the token ID of their NFT ID
    function getAutIDByOwner(address autIDOwner) external view override returns (uint256) {
        return _autIDByOwner[autIDOwner];
    }

    function getTotalCommitment(address autIDHolder) public view override returns (uint256) {
        address[] memory userDAOs = holderToDAOs[autIDHolder];

        uint256 totalCommitment = 0;
        for (uint256 index = 0; index < userDAOs.length; index++) {
            totalCommitment += holderToDAOMembershipData[autIDHolder][userDAOs[index]].commitment;
        }
        return totalCommitment;
    }

    function getAutIDHolderByUsername(string memory username) public view override returns (address) {
        return autIDUsername[_toLower(username)];
    }

    function getNextTokenID() public view override returns (uint256) {
        return _tokenIds.current();
    }

    /// ERC 721 s

    /// @notice ERC721 _transfer() Disabled
    /// @dev _transfer() has been n
    /// @dev reverts on transferFrom() and safeTransferFrom()
    function _transfer(address from, address to, uint256 tokenId) internal override {
        require(false, "AutID: AutID transfer disabled");
    }

    /// @notice ERC721 _safeTransfer() Disabled
    /// @dev _safeTransfer() has been n
    /// @dev reverts on transferFrom() and safeTransferFrom()
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal override {
        require(false, "AutID: AutID transfer disabled");
    }

    function _msgSender() internal view override(ContextUpgradeable, ERC2771Recipient) returns (address) {
        return ERC2771Recipient._msgSender();
    }

    function _msgData() internal view override(ContextUpgradeable, ERC2771Recipient) returns (bytes calldata) {
        return ERC2771Recipient._msgData();
    }
    // Function used to lowercase a string

    function _toLower(string memory _base) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        for (uint256 i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = _lower(_baseBytes[i]);
        }
        return string(_baseBytes);
    }

    function _lower(bytes1 _b1) private pure returns (bytes1) {
        if (_b1 >= 0x41 && _b1 <= 0x5A) {
            return bytes1(uint8(_b1) + 32);
        }

        return _b1;
    }
}
