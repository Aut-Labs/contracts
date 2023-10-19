// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface IAuthorization {
    function authCall(
        address sender,
        bytes32 componentKey,
        bytes4 selector
    )
        external
        view
        returns(bool);
}
