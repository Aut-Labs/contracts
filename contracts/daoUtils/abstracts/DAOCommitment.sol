//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../interfaces/get/IDAOCommitment.sol";

/// @title DAOExpander
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
abstract contract DAOCommitment is IDAOCommitment {
    event CommitmentSet();

    uint256 _commitment;

    function _setCommitment(uint256 commitment) internal {
        require(commitment > 0 && commitment < 11, "invalid commitment");

        _commitment = commitment;
        emit CommitmentSet();
    }

    function getCommitment() public view override returns (uint256) {
        return _commitment;
    }
}
