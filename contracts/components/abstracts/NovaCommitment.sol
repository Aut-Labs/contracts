//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../interfaces/get/INovaCommitment.sol";

/// @title Nova
/// @notice The extension of each Nova that integrates Aut
/// @dev The extension of each Nova that integrates Aut
abstract contract NovaCommitment is INovaCommitment {
    event CommitmentSet(uint256);

    uint256 _commitment;

    function _setCommitment(uint256 commitment) internal {
        require(commitment > 0 && commitment < 11, "invalid commitment");

        _commitment = commitment;
        emit CommitmentSet(commitment);
    }

    function getCommitment() public view override returns (uint256) {
        return _commitment;
    }
}
