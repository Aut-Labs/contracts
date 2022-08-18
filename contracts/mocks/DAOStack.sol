//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title DAOStack
/// @notice Mock DAOStack DAO for testing
contract DAOStack {
    IERC20 public nativeToken;
    IERC20 public nativeReputation;

    constructor(IERC20 _nativeToken, IERC20 _nativeReputation) {
        nativeToken = _nativeToken;
        nativeReputation = _nativeReputation;
    }
}
