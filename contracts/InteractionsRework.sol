// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "solidity-rlp/contracts/RLPReader.sol";

interface IAutIDMembership {
    function tokenIdForAccount(address) external view returns(uint256);
}

contract InteractionRegistry is AccessControl {
    event InteractionCreated(
        bytes32 indexed interactionHash,
        uint16 chainId,
        address callTarget,
        bytes4 selector,
        string funcSig
    );

    struct TInteractionData {
        uint16 chainId;
        address callTarget;
        bytes4 functionSelector;
    }

    bytes32 public constant INTERACTION_TYPEHASH 
        = keccak256("TInteractionData(uint16 chainId,address callTarget,bytes4 functionSelector)");

    bytes32 public constant CREATOR_ROLE = keccak256("CREATOR_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER(CREATOR)_ROLE");

    mapping(bytes32 => TInteractionData) public interactionData;

    constructor(address initialCreatorManager) {
        _setRoleAdmin(CREATOR_ROLE, MANAGER_ROLE);
        _grantRole(MANAGER_ROLE, initialCreatorManager);
        _grantRole(CREATOR_ROLE, initialCreatorManager);
    }

    function verifyFunctionSignature(bytes32 intHash, string memory funcSig) external view returns(bool) {
        return bytes4(keccak256(bytes(funcSig))) == interactionData[intHash].functionSelector;
    }

    function createInteraction(uint16 chainId, address contract_, string memory functionSignature) external {
        _checkRole(CREATOR_ROLE);

        TInteractionData memory data = TInteractionData({
            chainId: chainId,
            callTarget: contract_,
            functionSelector: bytes4(keccak256(bytes(functionSignature)))
        });
        bytes32 intHash = _getInteractionHash(data);
        interactionData[intHash] = data;

        emit InteractionCreated(
            intHash,
            chainId,
            data.callTarget,
            data.functionSelector,
            functionSignature
        );
    }

    function _getInteractionHash(TInteractionData memory data) internal pure returns(bytes32) {
        return keccak256(abi.encode(INTERACTION_TYPEHASH, data.chainId, data.callTarget, data.functionSelector));
    }
}


// assume: txHash <--> chainId, contract, signature 
contract InteractionTxMapper is AccessControl {

    event MerkleTreeUpdated(address indexed relayer, bytes32 merkleRoot, bytes32 proofsHash);

    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER(RELAYER)_ROLE");
    bytes32 public constant RELAYER_ROLE = keccak256("RELAYER_ROLE");

    bytes32 public merkleRoot;
    bytes32 public ipfsProofsHash;

    uint64 public updatedAt;

    constructor(address initialRelayerManager) {
        _setRoleAdmin(RELAYER_ROLE, MANAGER_ROLE);
        _grantRole(MANAGER_ROLE, initialRelayerManager);
        _grantRole(RELAYER_ROLE, initialRelayerManager);
    }

    function isMatch(
        bytes32 txHash,
        bytes32 intHash,
        bytes32[] memory hashedPairsProof
    ) external view returns(bool) {
        // backend deserialized and made sure that txHash is indeed interaction inthash
        // by now it seems that any txHash could have at most corresponding intHash and vice-versa (except for funcSig collisions xD)
        return MerkleProof.verify(
            hashedPairsProof, 
            keccak256(abi.encodePacked(txHash, ':', intHash)),
            merkleRoot
        ); 
    }

    function update(bytes32 newMerkleRoot, bytes32 newIpfsProofsHash) external {
        _checkRole(RELAYER_ROLE);

        merkleRoot = newMerkleRoot;
        ipfsProofsHash = newIpfsProofsHash;
        updatedAt = uint64(block.timestamp);

        emit MerkleTreeUpdated(msg.sender, newMerkleRoot, newIpfsProofsHash);
    }
}


contract TxVerifier {
    using RLPReader for RLPReader.RLPItem;
    using RLPReader for RLPReader.Iterator;
    using RLPReader for bytes;

    enum ELegacyTx {
        nonce,
        gasPrice,
        gasLimit,
        to,
        value,
        data,
        v,
        r,
        s
    }

    enum EType02Tx {
        chainId,
        nonce,
        max_priority_fee_per_gas,
        max_fee_per_gas,
        gas_limit,
        destination,
        amount,
        data,
        access_list,
        signature_y_parity,
        signature_r,
        signature_s
    }

    struct TTxVerifiedData {
        bytes32 txHash;
        uint16 chainId;
        address from;
        address to;
        bytes4 selector;
        uint256 value;
        bytes callArgs;
    }

    function _e2ui(ELegacyTx x) private pure returns(uint256) {
        return uint256(bytes32(bytes1(uint8(x))));
    }

    function _e2ui(EType02Tx x) private pure returns(uint256) {
        return uint256(bytes32(bytes1(uint8(x))));
    }

    function _verifyLegacyTx(uint16 chainId_, bytes32 txHash, bytes memory rlpBytes) 
        internal 
        pure
        returns(TTxVerifiedData memory verified) 
    {
        RLPReader.RLPItem memory item = rlpBytes.toRlpItem();
        RLPReader.RLPItem[] memory ls = item.toList();

        verified.chainId = chainId_;
        verified.txHash = item.rlpBytesKeccak256();

        if (verified.txHash != txHash) {
            delete verified;
            return verified;
        }

        // base
        uint16 nonce = uint16(bytes2(ls[_e2ui(ELegacyTx.nonce)].toBytes()));
        uint256 gasPrice = ls[_e2ui(ELegacyTx.gasPrice)].toUint();
        uint256 gasLimit = ls[_e2ui(ELegacyTx.gasLimit)].toUint();
        verified.to = ls[_e2ui(ELegacyTx.to)].toAddress();
        verified.value = ls[_e2ui(ELegacyTx.value)].toUint();
        bytes memory data = ls[_e2ui(ELegacyTx.data)].toBytes();
        // sig
        uint8 v = uint8(bytes1(ls[_e2ui(ELegacyTx.v)].toBytes()));
        bytes32 r = bytes32(ls[_e2ui(ELegacyTx.r)].toUint());
        bytes32 s = bytes32(ls[_e2ui(ELegacyTx.s)].toUint());

        bytes memory tb;
        for (uint256 i; i != 6; ++i) {
            tb = bytes.concat(tb, ls[i].toRlpBytes());
        }
        RLPReader.RLPItem memory txbase = tb.toRlpItem();
        bytes32 sighash = txbase.rlpBytesKeccak256();
        verified.from = ecrecover(sighash, v, r, s);

        verified.selector = bytes4(abi.encodePacked(data[0], data[1], data[2], data[3]));
    }

    function _verifyType02Tx(bytes memory rlpBytes)
        internal
        view
        returns(TTxVerifiedData memory)
    {}

    function verifyTx(uint16 chainId, bytes memory rlpBytes) external view returns(bool) {

    }
}

// struct TBaseTxData {
//     address to;
//     uint64 nonce;
//     bytes data;
//     uint256 value;
//     uint256 gasPrice;
//     uint256 gasLimit;
//     uint16 chainId;
// }
