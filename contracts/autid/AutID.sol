// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IAutID} from "./IAutID.sol";

import {
    ERC721URIStorageUpgradeable,
    ERC721Upgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ERC2771ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol";

import {AutIDUtils} from "./AutIDUtils.sol";

contract AutID is IAutID, AutIDUtils, ERC721URIStorageUpgradeable, OwnableUpgradeable, ERC2771ContextUpgradeable {
    error ConflictingRecord();
    error UntransferableToken();

    address public novaRegistry;
    address public localReputation;
    mapping(bytes32 => uint256) public tokenIdForUsername;
    mapping(address => uint256) public tokenIdForAccount;
    uint256 private _tokenId;

    constructor(address trustedForwarder_) ERC2771ContextUpgradeable(trustedForwarder_) {}

    function initialize(address initialOwner) public initializer {
        __ERC721_init("AutID", "AUT");
        __Ownable_init(initialOwner);
    }

    /// @inheritdoc IAutID
    function setNovaRegistry(address newNovaRegistry) external onlyOwner {
        _revertForZeroAddress(newNovaRegistry);

        novaRegistry = newNovaRegistry;

        emit NovaRegistrySet(newNovaRegistry);
    }

    /// @inheritdoc IAutID
    function setLocalReputation(address newLocalReputation) external onlyOwner {
        _revertForZeroAddress(newLocalReputation);

        localReputation = newLocalReputation;

        emit LocalReputationSet(newLocalReputation);
    }

    /// @inheritdoc IAutID
    function updateTokenURI(string memory uri) external {
        address account = _msgSender();
        _revertForZeroAddress(account);
        uint256 tokenId = tokenIdForAccount[account];
        _revertForInvalidTokenId(tokenId);

        _setTokenURI(tokenId, uri);
    }

    /// @inheritdoc IAutID
    function createRecordAndJoinNova(
        uint256 role,
        uint256 commitment,
        address nova,
        string memory username_,
        string memory optionalURI
    ) external {
        address account = _msgSender();
        _revertForZeroAddress(account);

        _createRecord(account, username_, optionalURI);
        _joinNova(account, role, commitment, nova);

        emit AutIDCreated(account, _tokenId, username_, nova, role, commitment, optionalURI);
    }

    function transferFrom(address, address, uint256) public pure override(ERC721Upgradeable, IERC721) {
        revert UntransferableToken();
    }

    /// @inheritdoc IAutID
    function joinNova(uint256 role, uint256 commitment, address nova) public {
        address account = _msgSender();
        _revertForZeroAddress(account);
        uint256 tokenId = tokenIdForAccount[account];
        _revertInvalidTokenId(tokenId);

        _joinNova(account, role, commitment, nova);
    }

    function _joinNova(address account, uint256 role, uint256 commitment, address nova) internal {
        address novaRegistryAddress = novaRegistry;
        _revertForZeroAddress(novaRegistryAddress);
        _revertForZeroAddress(nova);
        _revertForInvalidCommitment(commitment);
        _revertForUncheckedNova(novaRegistryAddress, nova);
        _revertForCanNotJoinNova(nova, account, role);
        // todo: add min commitment check

        INovaMembershipSet(nova).join(account, role);

        emit NovaJoined(account, role, commitment, nova);
    }

    function _createRecord(address account, string memory username_, string memory optionalURI) internal {
        _revertForInvalidUsername(username_);
        bytes32 username;
        assembly {
            username := mload(add(username_, 32))
        }
        if (tokenIdForUsername[username] != 0 || tokenIdForAccount[account] != 0) {
            revert ConflictingRecord();
        }

        uint256 tokenId = ++_tokenId;
        _mint(account, tokenId);
        _setTokenURI(tokenId, optionalURI);
        tokenIdForUsername[username] = tokenId;
        tokenIdForAccount[account] = tokenId;

        emit RecordCreated(tokenId, account, username_, optionalURI);
    }

    uint256[45] private __gap;
}
