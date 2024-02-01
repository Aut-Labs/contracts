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
    error MinCommitmentNotReached();
    error InvalidTokenId();
    error NovaUserMissmatch();

    uint256 private constant MAX_GLOBAL_COMMITMENT = 10;
    uint256 private constant MIN_GLOBAL_COMMITMENT = 1;

    function _revertForZeroAddress(address addr) internal pure {
        if (addr == address(0)) {
            revert ZeroAddress();
        }
    }

    function _revertForInvalidCommitment(uint256 commitment) internal pure {
        if (!(commitment > MIN_GLOBAL_COMMITMENT && commitment < MAX_GLOBAL_COMMITMENT)) {
            revert InvalidCommitment();
        }
    }

    function _revertForInvalidUsername(string memory username_) internal pure {
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

    function _revertForUncheckedNova(address novaRegistry_, address nova) internal view {
        if (!INovaRegistry(novaRegistry_).checkNova(nova)) {
            revert UncheckedNova();
        }
    }

    function _revertForCanNotJoinNova(address nova, address account, uint256 role) internal view {
        if (!INova(nova).canJoin(account, role)) {
            revert CanNotJoinNova();
        }
    }

    function _revertForMinCommitmentNotReached(
        address nova,
        uint256 declaredCommitment
    ) internal view {
        if (INova(nova).commitment() > declaredCommitment) {
            revert MinCommitmentNotReached();
        }
    } 

    function _revertForInvalidTokenId(uint256 tokenId) internal pure {
        if (tokenId == 0) {
            revert InvalidTokenId();
        }
    }

    function _revertForNovaUserMissmatch(address account, address user) internal pure {
        if (account != user) {
            revert NovaUserMissmatch();
        }
    }
}
