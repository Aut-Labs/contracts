//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../daoStandards/IColony.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Colony
/// @notice Mock Colony DAO for testing
contract Colony is IColony {

    ColonyToken _token;

    constructor(address __token) {
        _token = ColonyToken(__token);
    }

    function token() external view override returns (address) {
        return address(_token);
    }
}

contract ColonyToken { // ERC20
    mapping (address => uint) balances;

    function increaseReputation(address member) external {
        balances[member]++;
    }

    function balanceOf(address member) external view returns (uint256) {
        return balances[member];
    }
}
