// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {
    ERC1155Upgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {
    ERC1155URIStorageUpgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155URIStorageUpgradeable.sol";
import {
    ERC1155SupplyUpgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import {
    AccessControlUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

/// @title a ERC1155 upgradeable contract with metadata contract for interactions
contract InteractionFactory is
    ERC1155URIStorageUpgradeable,
    ERC1155SupplyUpgradeable,
    AccessControlUpgradeable
{
    /// @notice en event emmited on interactionURI update
    /// @param sender sender address of the update
    /// @param interactionId id of interaction
    /// @param uri the uri itself
    event InteractionURIUpdated(
        address indexed sender,
        uint256 indexed interactionId,
        string uri
    );
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
    /// @notice role to manage token URI
    bytes32 public constant URI_ROLE = keccak256("URI");

    /// @notice a variable that indicates whether tokens are non-transferable
    bool public isNonTransferable = false;
    /// @notice a variable that stores mint timestamps for each interaction id
    mapping(
        uint256 interactionId => mapping(
            uint256 id => 
                uint64 timestamp
        )
    ) public mintedAt;

    constructor() {
        _disableInitializers();
    }

    function initialize(address initialManager) public initializer {
        if (address(initialManager) == address(0)) {
            revert InitialManagerEmptyError();
        }
        __ERC1155_init(""); // TODO: URI
        _setRoleAdmin(MINTER_ROLE, MANAGER_ROLE);
        _setRoleAdmin(URI_ROLE, MANAGER_ROLE);
        _grantRole(MANAGER_ROLE, initialManager);
        _grantRole(MINTER_ROLE, initialManager);
        _grantRole(URI_ROLE, initialManager);
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
    function mintInteraction(
        address to,
        uint256 interactionId
    ) external {
        _checkRole(MINTER_ROLE);
        _mint(to, interactionId, 1, "");
        mintedAt[interactionId][totalSupply(interactionId)] = uint64(block.timestamp);
        emit InteractionMinted(to, interactionId);
    }

    /// @notice update tokenURI for the interaction by the owner of interaction token
    /// @param interactionId id of the interaction
    /// @param interactionUri new interaction URI
    function updateInteractionURI(uint256 interactionId, string memory interactionUri) external {
        if (bytes(interactionUri).length == 0) {
            revert MetadataURIEmptyError();
        }
        _checkRole(URI_ROLE);
        _setInteractionURI(interactionId, interactionUri);
    }

    /// @inheritdoc IERC1155
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public virtual override(ERC1155Upgradeable, IERC1155) {
        if (isNonTransferable) {
            revert TransferUnallowedError();
        } else {
            super.safeTransferFrom(from, to, id, value, data);
        }
    }

    function _setInteractionURI(uint256 interactionId, string memory interactionUri) internal {
        _setURI(interactionId, interactionUri);
        emit InteractionURIUpdated(msg.sender, interactionId, interactionUri);
    }
}