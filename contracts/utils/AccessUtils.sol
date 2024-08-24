//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IHub} from "../hub/interfaces/IHub.sol";

contract AccessUtils {

    error NotAdmin();
    error NotHub();
    error NotAutId();

    struct AccessUtilsStorage {
        address hub;
        address autId;
    }

    // keccak256(abi.encode(uint256(keccak256("aut.storage.AccessUtils")) - 1))
    bytes32 private constant AccessUtilsStorageLocation = 0x25ef93b6ca8ff6ebe5276b45a88190020a874aa29e4443419cb4b5e12922d9a1;

    function _getAccessUtilsStorage() private pure returns (AccessUtilsStorage storage $) {
        assembly {
            $.slot := AccessUtilsStorageLocation
        }
    }

    function _init_AccessUtils(
        address _hub,
        address _autId
    ) internal {
        AccessUtilsStorage storage $ = _getAccessUtilsStorage();
        $.hub = _hub;
        $.autId = _autId;
    }

    function isAdmin(address who) public view returns (bool) {
        return IHub(hub()).isAdmin(who);
    }

    function hub() public view returns (address) {
        AccessUtilsStorage storage $ = _getAccessUtilsStorage();
        return $.hub;
    }

    function autId() public view returns (address) {
        AccessUtilsStorage storage $ = _getAccessUtilsStorage();
        return $.autId;
    }

    function _revertIfNotAdmin() internal view {
        if (!isAdmin(msg.sender)) revert NotAdmin();
    }

    function _revertIfNotHub() internal view {
        if (msg.sender != hub()) revert NotHub();
    }

    function _revertIfNotAutId() internal view {
        if (msg.sender != autId()) revert NotAutId();
    }
}