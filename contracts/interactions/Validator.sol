// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


contract ValidatorNode is Ownable {
    event EpochAdded(bytes32, uint128);
    event RelayerSet(address, bool);

    mapping(address => bool) internal _isRelayer;

    bytes32[] public merkleRoots;
    uint128[] public epochTimestamps;

    constructor() {}

    function epochFor(uint128 timestamp) external view returns(bool covered, uint128) {
        uint256 length = epochTimestamps.length;
        if (length == 0) {
            return (false, 0);
        }
        uint128 right = uint128(length) - 1;
        if (timestamp > epochTimestamps[right]) {
            return (false, type(uint128).max);
        }
        uint128 left = 0;
        while(right != left) {
            uint128 mid = left + ((right - left) >> 1);
            if (epochTimestamps[mid] >= timestamp) {
                right = mid;
            } else {
                left = mid;
            }
        }
        return (true, left);
    }

    function currentEpoch() external view returns(uint128) {
        return uint128(merkleRoots.length);
    }

    function verifyEntry(
        uint128 epoch_,
        bytes32 entryHash,
        bytes32[] memory merkleProof
    )
        external
        view
        returns(bool) 
    {
        return MerkleProof.verify(merkleProof, merkleRoots[epoch_], entryHash);
    }

    function addEpoch(bytes32 merkleRoot, uint128 timestamp) external {
        require(_isRelayer[msg.sender], "DatasetValidator");
        _addEpoch(merkleRoot, timestamp);
    }

    function addEpochsBulk(bytes32[] calldata roots, uint128[] calldata timestamps) external {
        // todo: optimize
        // assembly {
        //     sstore(merkleRoots.slot, add(sload(merkleRoots.slot), mload(roots))
        //     sstore(epochTimestamps.slot, add(sload(epochTimestamps.slot), mload(timestamps)))
        //     let x := 0
        //     for { let i := 0 } lt(i, 0x100) { i := add(i, 0x20) } {
        //         x := add(x, mload(i))
        //         sstore(add(merkleRoots, )
        //     }
        // }
        require(_isRelayer[msg.sender]);
        require(roots.length == timestamps.length);
        for (uint256 i; i != roots.length; ++i) {
            _addEpoch(roots[i], timestamps[i]);
        }
    }

    function setRelayer(address relayer, bool status) external {
        _checkOwner();
        if (!status) {
            delete _isRelayer[relayer];
        } else {
            _isRelayer[relayer] = true;
        }
        emit RelayerSet(relayer, status);
    }

    function _addEpoch(bytes32 merkleRoot, uint128 timestamp) internal {
        merkleRoots.push(merkleRoot);
        epochTimestamps.push(timestamp);
        emit EpochAdded(merkleRoot, timestamp);
    }
}
