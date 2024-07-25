// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/// @notice a dataset of interactions
interface IInteractionDataset {
    /// @notice an event emitted on merkle tree root update
    /// @param relayer address of the relayer caused an update
    /// @param merkleRoot new merkle root pushed by the relayer
    /// @param proofsHash hash of the merkle tree source file (nullable)
    event MerkleRootUpdated(
        address indexed relayer,
        bytes32 indexed merkleRoot,
        bytes32 proofsHash
    );

    /// @notice a role that manage relayer role
    /// @return manager role
    function MANAGER_ROLE() external pure returns (bytes32 manager);

    /// @notice a role that manage and update merkle roots
    /// @return relayer role
    function RELAYER_ROLE() external pure returns (bytes32 relayer);

    /// @return current root of the merkle tree of interactions
    function merkleRoot() external view returns (bytes32 current);

    /// @return current ipfs hash for the full merkle tree file
    function proofsHash() external view returns (bytes32 current);

    /// @return timestamp of the last update of the merkle tree
    function updatedAt() external view returns (uint64 timestamp);

    /// @return number of times that merkle tree has been updated
    function epoch() external view returns (uint32 number);

    /// @dev checks if the given transaction hash match given interaction id
    /// @param txId transaction hash
    /// @param interactionId interaction id (see InteractionFactory contract)
    /// @return status of inclusion in the interaction dataset for the given entry
    function hasEntry(
        bytes32 txId,
        bytes32 interactionId,
        bytes32[] memory hashedPairsProof
    ) external view returns (bool status);

    /// @dev updates merkle tree (invoked by "relayer" role)
    /// @param nextMerkleRoot root hash of the next merkle tree
    /// @param nextProofsHash next proofs hash
    function updateRoot(bytes32 nextMerkleRoot, bytes32 nextProofsHash) external;
}

/// @title a helper contract for the interaction dataset with error definitions
abstract contract InteractionDatasetErrorHelper {
    /// @notice raised when initialManager is zero address
    error InitialManagerEmptyError();
}

contract InteractionDataset is
    IInteractionDataset,
    InteractionDatasetErrorHelper,
    AccessControl
{
    /// @inheritdoc IInteractionDataset
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    /// @inheritdoc IInteractionDataset
    bytes32 public constant RELAYER_ROLE = keccak256("RELAYER_ROLE");

    /// @inheritdoc IInteractionDataset
    bytes32 public merkleRoot;
    /// @inheritdoc IInteractionDataset
    bytes32 public proofsHash;

    /// @inheritdoc IInteractionDataset
    uint64 public updatedAt;
    /// @inheritdoc IInteractionDataset
    uint32 public epoch;

    constructor(address initialRelayerManager) {
        if (initialRelayerManager == address(0)) {
            revert InitialManagerEmptyError();
        }
        _setRoleAdmin(RELAYER_ROLE, MANAGER_ROLE);
        _grantRole(MANAGER_ROLE, initialRelayerManager);
        _grantRole(RELAYER_ROLE, initialRelayerManager);
    }

    /// @inheritdoc IInteractionDataset
    function hasEntry(
        bytes32 txId,
        bytes32 interactionId,
        bytes32[] calldata hashedPairsProof
    ) external view returns (bool) {
        return
            MerkleProof.verifyCalldata(
                hashedPairsProof,
                keccak256(abi.encodePacked(txId, ":", interactionId)),
                merkleRoot
            );
    }

    /// @inheritdoc IInteractionDataset
    function updateRoot(bytes32 nextMerkleRoot, bytes32 nextProofsHash) external {
        _checkRole(RELAYER_ROLE);

        merkleRoot = nextMerkleRoot;
        proofsHash = nextProofsHash;
        updatedAt = uint64(block.timestamp);
        ++epoch;

        emit MerkleRootUpdated(msg.sender, nextMerkleRoot, nextProofsHash);
    }
}