// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {AutIdClaimAllowlist} from  "./utils/Allowlist.sol";

contract Bootstrapper {
    address internal allowlist; 

    // have set this value after the contract is created
    // <Allowlist> <--> Bootstrapper
    // it could be avoided if `Create2` were used 
    function setAllowlist(address allowlist_) internal {
        allowlist = allowlist_; 
    }

    // AutIdClaimAllowlist(allowlist).confirmClaim(msg.sender)
}
