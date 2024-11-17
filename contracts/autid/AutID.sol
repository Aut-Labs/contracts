//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

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
import {IMembership} from "../membership/IMembership.sol";

contract AutID is AutIDUtils, ERC721URIStorageUpgradeable, OwnableUpgradeable, ERC2771ContextUpgradeable, IAutID {
    struct AutIDStorage {
        uint256 tokenId;
        address hubRegistry;
        address localReputation;
        mapping(bytes32 => uint256) tokenIdForUsername;
        mapping(address => uint256) tokenIdForAccount;
        mapping(address => uint32) mintedAt;
    }
    // keccak256(abi.encode(uint256(keccak256("aut.storage.AutID")) - 1))
    bytes32 private constant AutIDStorageLocation = 0x965a41ae9c39ec634f499718a240ff6463f22d8ae786856bf7c0daba4c9f58b3;

    function _getAutIDStorage() private pure returns (AutIDStorage storage $) {
        assembly {
            $.slot := AutIDStorageLocation
        }
    }

    function version() external pure returns (uint256 major, uint256 minor, uint256 patch) {
        return (0, 1, 0);
    }

    constructor(address trustedForwarder_) ERC2771ContextUpgradeable(trustedForwarder_) {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __ERC721_init("AutID", "AUT");
        __Ownable_init(initialOwner);
    }

    /// @inheritdoc IAutID
    function setHubRegistry(address newHubRegistry) external onlyOwner {
        _revertForZeroAddress(newHubRegistry);

        AutIDStorage storage $ = _getAutIDStorage();
        $.hubRegistry = newHubRegistry;

        emit HubRegistrySet(newHubRegistry);
    }

    /// @inheritdoc IAutID
    function setLocalReputation(address newLocalReputation) external onlyOwner {
        _revertForZeroAddress(newLocalReputation);

        AutIDStorage storage $ = _getAutIDStorage();
        $.localReputation = newLocalReputation;

        emit LocalReputationSet(newLocalReputation);
    }

    /// @inheritdoc IAutID
    function mint(
        uint256 role,
        uint8 commitment,
        address hub,
        string memory username,
        string memory optionalURI
    ) external {
        createRecordAndJoinHub(role, commitment, hub, username, optionalURI);
    }

    /// @inheritdoc IAutID
    function createRecordAndJoinHub(
        uint256 role,
        uint8 commitment,
        address hub,
        string memory username,
        string memory optionalURI
    ) public {
        address account = _msgSender();
        AutIDUtils._revertForZeroAddress(account);

        AutIDStorage storage $ = _getAutIDStorage();
        $.mintedAt[account] = uint32(block.timestamp);

        _createRecord(account, username, optionalURI);
        _joinHub(account, role, commitment, hub);
    }

    function getUserHubs(address user) external view returns (address[] memory) {
        return IHubRegistry(hubRegistry()).userHubs(user);
    }

    function currentRole(address hub, address user) external view returns (uint256) {
        return IMembership(hub).currentRole(user);
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

    /// @inheritdoc IAutID
    function setTokenURI(string memory uri) external {
        address account = _msgSender();
        _revertForZeroAddress(account);

        uint256 tokenId_ = tokenIdForAccount(account);
        _revertForInvalidTokenId(tokenId_);
        _setTokenURI(tokenId_, uri);

        emit TokenMetadataUpdated(tokenId_, account, uri);
    }

    /// @inheritdoc IAutID
    function joinHub(uint256 role, uint8 commitment, address hub) public {
        address account = _msgSender();
        _revertForZeroAddress(account);

        _revertForInvalidTokenId(tokenIdForAccount(account));

        _joinHub(account, role, commitment, hub);
    }

    function _joinHub(address account, uint256 role, uint8 commitment, address hub) internal {
        address hubRegistryAddress = hubRegistry();
        _revertForZeroAddress(hubRegistryAddress);
        _revertForZeroAddress(hub);
        _revertForInvalidCommitment(commitment);
        _revertIfHubDoesNotExist(hubRegistryAddress, hub);
        _revertForCanNotJoinHub(hub, account, role);
        _revertForMinCommitmentNotReached(hub, commitment);

        IHubRegistry(hubRegistryAddress).join({hub: hub, member: account, role: role, commitment: commitment});

        emit HubJoined(account, role, commitment, hub);
    }

    function _createRecord(address account, string memory username, string memory optionalURI) internal {
        _revertForInvalidUsername(username);
        bytes32 username_;
        assembly {
            username_ := mload(add(username, 32))
        }
        AutIDStorage storage $ = _getAutIDStorage();

        if ($.tokenIdForUsername[username_] != 0 || $.tokenIdForAccount[account] != 0) {
            revert ConflictingRecord();
        }

        uint256 tokenId_ = ++$.tokenId;
        _mint(account, tokenId_);
        _setTokenURI(tokenId_, optionalURI);
        $.tokenIdForUsername[username_] = tokenId_;
        $.tokenIdForAccount[account] = tokenId_;

        emit RecordCreated(tokenId_, account, username, optionalURI);
    }

    function tokenId() external view returns (uint256) {
        AutIDStorage storage $ = _getAutIDStorage();
        return $.tokenId;
    }

    function hubRegistry() public view returns (address) {
        AutIDStorage storage $ = _getAutIDStorage();
        return $.hubRegistry;
    }

    function localReputation() external view returns (address) {
        AutIDStorage storage $ = _getAutIDStorage();
        return $.localReputation;
    }

    function tokenIdForUsername(bytes32 usernameHash) external view returns (uint256) {
        AutIDStorage storage $ = _getAutIDStorage();
        return $.tokenIdForUsername[usernameHash];
    }

    function tokenIdForAccount(address who) public view returns (uint256) {
        AutIDStorage storage $ = _getAutIDStorage();
        return $.tokenIdForAccount[who];
    }

    function mintedAt(address who) external view returns (uint256) {
        AutIDStorage storage $ = _getAutIDStorage();
        return $.mintedAt[who];
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
}
