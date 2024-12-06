//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IHub} from "../hub/interfaces/IHub.sol";
import {IHubRegistry} from "../hub/interfaces/IHubRegistry.sol";

abstract contract AutIDUtils {
    error ZeroAddress();
    error InvalidCommitment();
    error InvalidUsername();
    error UncheckedHub();
    error CanNotJoinHub();
    error MinCommitmentNotReached();
    error InvalidTokenId();

    uint256 private constant MAX_GLOBAL_COMMITMENT = 10;
    uint256 private constant MIN_GLOBAL_COMMITMENT = 1;

    function _revertForZeroAddress(address addr) internal pure {
        if (addr == address(0)) {
            revert ZeroAddress();
        }
    }

    function _revertForInvalidCommitment(uint256 commitmentLevel) internal pure {
        if (!(commitmentLevel >= MIN_GLOBAL_COMMITMENT && commitmentLevel <= MAX_GLOBAL_COMMITMENT)) {
            revert InvalidCommitment();
        }
    }

    function _revertForInvalidUsername(string memory username_) internal pure {
        bytes memory username = bytes(username_);
        uint256 i;
        for (; i != username.length; ++i) {
            if (
                // 'a' <= ... <= 'z'
                // '0' <= ... <= '9'
                // '-' == ...
                !((username[i] >= 0x61 && username[i] <= 0x7A) ||
                    (username[i] >= 0x30 && username[i] <= 0x39) ||
                    username[i] == 0x2D)
            ) {
                revert InvalidUsername();
            }
        }
        if (i == 0 || i > 32) {
            revert InvalidUsername();
        }
    }

    function _revertIfHubDoesNotExist(address hubRegistry_, address hub) internal view {
        if (!IHubRegistry(hubRegistry_).isHub(hub)) {
            revert UncheckedHub();
        }
    }

    function _revertForCanNotJoinHub(address hub, address account, uint256 role) internal view {
        if (!IHub(hub).canJoin(account, role)) {
            revert CanNotJoinHub();
        }
    }

    function _revertForMinCommitmentNotReached(address hub, uint256 declaredCommitment) internal view {
        if (IHub(hub).commitmentLevel() > declaredCommitment) {
            revert MinCommitmentNotReached();
        }
    }

    function _revertForInvalidTokenId(uint256 tokenId) internal pure {
        if (tokenId == 0) {
            revert InvalidTokenId();
        }
    }
}
