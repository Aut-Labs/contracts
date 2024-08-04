// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {
    ERC721URIStorageUpgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

/// @title a ERC721 upgradeable contract with metadata contract for interactions
contract InteractionFactory is ERC721URIStorageUpgradeable, AccessControlUpgradeable {
    /// @notice en event emmited on interactionURI update
    /// @param sender sender address of the update
    /// @param interactionId id of interaction
    /// @param uri the uri itself
    event InteractionURIUpdated(address indexed sender, uint256 indexed interactionId, string uri);
    /// @notice en event emitted on interaction mint
    event InteractionMinted(address indexed sender, uint256 interactionId);
    /// @notice an event emitted on transferability change
    event TransferabilitySet(address indexed sender, bool isTransferable);

    /// @notice an error raised when initialManager is zero address
    error InitialManagerEmptyError();
    /// @notice an error raised when attemtep to transfer token
    error TransferUnallowedError();
    /// @notice en error raised when metadataURI is empty
    error MetadataURIEmptyError();

    /// @notice a role that manage minter role and trasferability
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    /// @notice a role that manage minting
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @notice a variable that indicates whether tokens are non-transferable
    bool public isNonTransferable = false;
    /// @notice a variable that stores mint timestamps for each interaction id
    mapping(uint256 interactionId => uint64 timestamp) public mintedAt;

    function initialize(address initialManager) public initializer {
        if (address(initialManager) == address(0)) {
            revert InitialManagerEmptyError();
        }
        __ERC721_init("InteractionFactory", "IF");
        _setRoleAdmin(MINTER_ROLE, MANAGER_ROLE);
        _grantRole(MANAGER_ROLE, initialManager);
        _grantRole(MINTER_ROLE, initialManager);
    }

    /// @notice enable or disable transferability of the whole collection
    /// @param isTransferable true, if the collection should be transferable, false otherwise
    function setTransferability(bool isTransferable) external {
        _checkRole(MANAGER_ROLE);
        isNonTransferable = !isTransferable;
        emit TransferabilitySet(msg.sender, isTransferable);
    }

    /// @notice mint interaction
    /// @param to address of the recipient of the interaction token
    /// @param interactionId id of the interaction
    /// @param uri tokenURI
    function mintInteraction(address to, uint256 interactionId, string memory uri) external {
        _checkRole(MINTER_ROLE);
        _mint(to, interactionId);
        _setInteractionURI(interactionId, uri);
        mintedAt[interactionId] = uint64(block.timestamp);
        emit InteractionMinted(to, interactionId);
    }

    /// @notice update tokenURI for the interaction by the owner of interaction token
    /// @param interactionId id of the interaction
    /// @param uri new tokenURI
    function updateInteractionURI(uint256 interactionId, string memory uri) external {
        if (bytes(uri).length == 0) {
            revert MetadataURIEmptyError();
        }
        address owner = _ownerOf(interactionId);
        _checkAuthorized(owner, msg.sender, interactionId);
        _setInteractionURI(interactionId, uri);
    }

    /// @inheritdoc IERC721
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override(ERC721Upgradeable, IERC721) {
        if (isNonTransferable) {
            revert TransferUnallowedError();
        } else {
            super.transferFrom(from, to, tokenId);
        }
    }

    /// @inheritdoc IERC165
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721URIStorageUpgradeable, AccessControlUpgradeable) returns (bool) {
        return (ERC721URIStorageUpgradeable.supportsInterface(interfaceId) ||
            AccessControlUpgradeable.supportsInterface(interfaceId));
    }

    function _setInteractionURI(uint256 interactionId, string memory uri) internal {
        _setTokenURI(interactionId, uri);
        emit InteractionURIUpdated(msg.sender, interactionId, uri);
    }
}
