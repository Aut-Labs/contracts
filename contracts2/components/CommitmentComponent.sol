//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "../base/ComponentBase.sol";

/// @title Commitment component
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
contract CommitmentComponent is ComponentBase {
    event CommitmentSet(uint256);

    uint256 internal _commitment;

    function setCommitment(uint256 commitment) external novaCall {
        require(
            commitment > 0 && commitment < 11,
            "CommitmentComponent: invalid commitment"
        );
        _commitment = commitment;
        emit CommitmentSet(commitment);
    }

    function getCommitment() public view returns (uint256) {
        return _commitment;
    }
}
