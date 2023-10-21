//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "../base/ComponentBase.sol";
import "../utils/Semver.sol";

/// @title Commitment component
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
contract CommitmentComponent is ComponentBase, Semver(0, 1, 0) {
    event CommitmentSet(uint256);

    uint256 public constant MAX_COMMITMENT_LEVEL = 10;
    uint256 public constant MIN_COMMITMENT_LEVEL = 1;

    uint256 public commitment;

    function setCommitment(uint256 commitment_) external novaCall {
        require(
            commitment_ >= MIN_COMMITMENT_LEVEL && commitment_ <= MAX_COMMITMENT_LEVEL,
            "CommitmentComponent: invalid commitment"
        );
        commitment = commitment_;
        emit CommitmentSet(commitment_);
    }
}
