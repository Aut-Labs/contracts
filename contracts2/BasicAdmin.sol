// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "./interfaces/IAccessControl.sol";

contract BasicAdmin is IAccessControl {
    event AdminSet(address);
    event AdminRemoved(address);

    mapping(address => bool) public isAdmin;

    modifier adminCall {
        require(isAdmin[msg.sender], "Access: not an admin");
        _;
    }

    constructor(address admin) {
        isAdmin[admin] = true;
    }

    function permitCall(
        address sender,
        bytes32,
        bytes4
    )
        external
        view
        returns(bool)
    {
        return isAdmin[sender];
    }

    function setAdmin(address newAdmin) external adminCall {
        require(newAdmin != address(0), "Admin: address zero");
        isAdmin[newAdmin] = true;
        emit AdminSet(newAdmin);
    }

    function removeAdmin(address exAdmin) external adminCall {
        require(exAdmin != address(0), "Admin: address zero");
        isAdmin[exAdmin] = false;
        emit AdminRemoved(exAdmin);
    }
}
