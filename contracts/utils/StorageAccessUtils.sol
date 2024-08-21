//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract StorageAccessUtils {
    address internal _hub;
    address internal _autID;

    function init_StorageAccessUtils(
        address hub_,
        address autID_
    ) public {
        _hub = hub_;
        _autId = autID_;
    }

    function isAdmin(address who) external view returns (bool) {
        return IHub(hub).isAdmin(who);
    }

    function hub() public view returns (address) {
        return _hub;
    }

    function autID() public view returns (address) {
        return _audID;
    }
}