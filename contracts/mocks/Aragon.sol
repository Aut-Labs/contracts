//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {IMiniMeToken, IAragonApp, IAragonKernel} from "../daoStandards/IAragon.sol";

contract AragonVotingApp is IAragonApp {
    // address private _token;
    IMiniMeToken public override token;

    constructor(address token_) {
        token = IMiniMeToken(token_);
    }
}

contract AragonTokenManagerApp is AragonVotingApp {
    constructor(address token_) AragonVotingApp(token_) {}

    function mintRole() external pure returns (bytes32) {
        return keccak256("MINT_ROLE");
    }
}
