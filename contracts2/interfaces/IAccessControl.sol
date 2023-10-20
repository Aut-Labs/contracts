// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface IAccessControl {
    function permitCall(
        address sender,
        bytes32 componentKey,
        bytes4 selector
    )
        external
        view
        returns(bool)
    ;
}
