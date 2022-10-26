//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IDAOCommitment.sol";

/// @title DAOExpander
/// @notice The extension of each DAO that integrates Aut
/// @dev The extension of each DAO that integrates Aut
abstract contract DAOCommitment is IDAOCommitment {

    uint _commitment;

    function setCommitment(uint commitment)
        public
        virtual
        override
    {
         require(
            commitment > 0 && commitment < 11,
            "Commitment should be between 1 and 10"
        );

        _commitment = commitment;
        emit CommitmentSet();
    }

    function getCommitment() public override view returns(uint) {
        return _commitment;
    }
}
