// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {INova} from "../nova/INova.sol";
import {INovaRegistry} from "../nova/INovaRegistry.sol";

abstract contract AutIDUtils {
    error ZeroAddress();
    error InvalidCommitment();
    error InvalidUsername();
    error UncheckedNova();
    error CanNotJoinNova();
    error InvalidTokenId();

    function _revertForZeroAddress(address addr) private pure {
        if (addr == address(0)) {
            revert ZeroAddress();
        }
    }

    function _revertForInvalidCommitment(uint256 commitment) private pure {
        if (!(commitment > 0 && commitment < 11)) {
            revert InvalidCommitment();
        }
    }

    function _revertForInvalidUsername(string memory username_) private pure {
        bytes memory username = bytes(username_);
        uint256 i;
        for (; i != username.length; ++i) {
            if (!(
                // 'a' <= ... <= 'z'
                (username[i] >= 0x61 && username[i] <= 0x7A) || 
                // '0' <= ... <= '9'
                (username[i] >= 0x30 && username[i] <= 0x39) ||
                // '-' == ...
                username[i] == 0x2D
            )) {
                revert InvalidUsername();
            }
        }
        if (i == 0 || i > 32) {
            revert InvalidUsername();
        }
    }

    function _revertForUncheckedNova(address novaRegistry_, address nova) private view {
        if (!INovaRegistry(novaRegistry_).checkNova(nova)) {
            revert UncheckedNova();
        }
    }

    function _revertForCanNotJoinNova(address nova, address account, uint256 role) private view {
        if (!INova(nova).canJoin(account, role)) {
            revert CanNotJoinNova();
        }
    }

    function _revertForInvalidTokenId(uint256 tokenId) private view {
        if (!tokenId) {
            revert InvalidTokenId();
        }
    }
}
