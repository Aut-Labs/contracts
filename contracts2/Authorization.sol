// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "./interfaces/IAuthorization.sol";

contract Admin is IAuthorization {
    event AdminSet(address);
    event AdminRemoved(address);

    mapping(address => bool) public isAdmin;

    constructor(address initialAdmin) {
        isAdmin[initialAdmin];
    }

    function authCall(
        address sender,
        bytes32,
        bytes4
    ) public view returns(bool) {
        return isAdmin[sender];
    }

    function setAdmin(address newAdmin) external {
        _requireAdmin();
        require(newAdmin != address(0), "Admin: address zero");
        isAdmin[newAdmin] = true;
        emit AdminSet(newAdmin);
    }

    function removeAdmin(address exAdmin) external {
        _requireAdmin();
        require(exAdmin != address(0), "Admin: address zero");
        isAdmin[exAdmin] = false;
        emit AdminRemoved(exAdmin);
    }

    function _requireAdmin() internal view {
        require(
            authCall(msg.sender, bytes32(0), bytes4(0)),
            "Admin: unauthorized"
        );
    }
}