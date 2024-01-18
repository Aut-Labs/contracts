// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract NovaUtils {
    error ZeroAddress();
    error InvalidMarket();
    error InvalidParameter();
    error InvalidCommitment();
    error InvalidMetadataUri();

    function _revertForZeroAddress(address who) internal pure {
        if (who == address(0)) {
            revert ZeroAddress();
        }
    }

    function _revertForInvalidMarket(uint256 market_) internal pure {
        if (market_ == 0 || market_ > 3) {
            revert InvalidMarket();
        }
    }

    function _revertForInvalidCommitment(uint256 commitment_) internal pure {
        if (commitment_ == 0 || commitment_ > 10) {
            revert InvalidCommitment();
        }
    }

    function _revertForInvalidMetadataUri(string memory metadataUri_) internal pure {
        if (bytes(metadataUri_).length == 0) {
            revert InvalidMetadataUri();
        }
    }

    function _revertForInvalidParameter(uint8 parameter) internal pure {
        if (parameter > 5 || parameter == 0) {
            revert InvalidParameter();
        }
    }
}
