//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IAutID} from "./IAutID.sol";

import {
    ERC721URIStorageUpgradeable,
    ERC721Upgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {
    ERC2771ContextUpgradeable,
    ContextUpgradeable
} from "@openzeppelin/contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol";

import {AutIDUtils} from "./AutIDUtils.sol";
import {IHub} from "../hub/interfaces/IHub.sol";
import {IHubRegistry} from "../hub/interfaces/IHubRegistry.sol";

contract AutID is AutIDUtils, ERC721URIStorageUpgradeable, OwnableUpgradeable, ERC2771ContextUpgradeable, IAutID {
    error ConflictingRecord();
    error UntransferableToken();

    uint256 private _tokenId;

    address public hubRegistry;
    address public localReputation;
    mapping(bytes32 => uint256) public tokenIdForUsername;
    mapping(address => uint256) public tokenIdForAccount;
    mapping(address => uint32) public mintedAt;

    constructor(address trustedForwarder_) ERC2771ContextUpgradeable(trustedForwarder_) {}

    function nextTokenId() external view returns (uint256) {
        return _tokenId + 1;
    }

    function initialize(address initialOwner) public initializer {
        __ERC721_init("AutID", "AUT");
        __Ownable_init(initialOwner);
    }

    /// @inheritdoc IAutID
    function setHubRegistry(address newHubRegistry) external onlyOwner {
        _revertForZeroAddress(newHubRegistry);

        hubRegistry = newHubRegistry;

        emit HubRegistrySet(newHubRegistry);
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
    function mint(
        uint256 role,
        uint8 commitment,
        address hub,
        string memory username_,
        string memory optionalURI
    ) external {
        createRecordAndJoinHub(role, commitment, hub, username_, optionalURI);
    }

    /// @inheritdoc IAutID
    function createRecordAndJoinHub(
        uint256 role,
        uint8 commitment,
        address hub,
        string memory username_,
        string memory optionalURI
    ) public {
        address account = _msgSender();
        AutIDUtils._revertForZeroAddress(account);
        mintedAt[account] = uint32(block.timestamp);

        _createRecord(account, username_, optionalURI);
        _joinHub(account, role, commitment, hub);
    }

    function listUserHubs(address user) external view returns (address[] memory) {
        return IHubRegistry(hubRegistry).listUserHubs(user);
    }

    // function userHubRole(address hub, address user) external view returns (uint256) {
    //     return IHub(hub).roles(user);
    // }

    // function userHubCommitmentLevel(address hub, address user) external view returns (uint256) {
    //     return IHub(hub).currentCommitmentLevels(user);
    // }

    // function userHubJoinedAt(address hub, address user) external view returns (uint256) {
    //     return IHub(hub).joinedAt(user);
    // }

    function transferFrom(address, address, uint256) public pure override(ERC721Upgradeable, IERC721) {
        revert UntransferableToken();
    }

    function setTokenURI(string memory uri) external {
        address account = _msgSender();
        _revertForZeroAddress(account);
        uint256 tokenId = tokenIdForAccount[account];
        _revertForInvalidTokenId(tokenId);
        _setTokenURI(tokenId, uri);

        emit TokenMetadataUpdated(tokenId, account, uri);
    }

    /// @inheritdoc IAutID
    function joinHub(uint256 role, uint8 commitment, address hub) public {
        address account = _msgSender();
        _revertForZeroAddress(account);
        uint256 tokenId = tokenIdForAccount[account];
        _revertForInvalidTokenId(tokenId);

        _joinHub(account, role, commitment, hub);
    }

    function _joinHub(address account, uint256 role, uint8 commitment, address hub) internal {
        address hubRegistryAddress = hubRegistry;
        _revertForZeroAddress(hubRegistryAddress);
        _revertForZeroAddress(hub);
        _revertForInvalidCommitment(commitment);
        _revertForUncheckedHub(hubRegistryAddress, hub);
        _revertForCanNotJoinHub(hub, account, role);
        _revertForMinCommitmentNotReached(hub, commitment);

        IHubRegistry(hubRegistryAddress).join({hub: hub, member: account, role: role, commitment: commitment});
        IHub(hub).join(account, role, commitment);

        emit HubJoined(account, role, commitment, hub);
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

    function _msgSender() internal view override(ERC2771ContextUpgradeable, ContextUpgradeable) returns (address) {
        return ERC2771ContextUpgradeable._msgSender();
    }

    function _msgData() internal view override(ERC2771ContextUpgradeable, ContextUpgradeable) returns (bytes calldata) {
        return ERC2771ContextUpgradeable._msgData();
    }

    function _contextSuffixLength()
        internal
        view
        override(ERC2771ContextUpgradeable, ContextUpgradeable)
        returns (uint256)
    {
        return ERC2771ContextUpgradeable._contextSuffixLength();
    }

    uint256[44] private __gap;
}
