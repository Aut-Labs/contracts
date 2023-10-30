pragma solidity 0.8.19;

import "./TestERC20.sol";
import {IMiniMeToken} from "../standards/IAragon.sol";

contract MiniMeToken is IMiniMeToken, TestERC20 {
    constructor(string memory name, string memory symbol, address initialAccount, uint256 totalSupply)
        payable
        TestERC20(name, symbol, initialAccount, totalSupply)
    {}
}
