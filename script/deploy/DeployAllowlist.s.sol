//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IAllowlist} from "../../contracts/utils/IAllowlist.sol";
import {IHubRegistry} from "../../contracts/hub/IHubRegistry.sol";

import {Allowlist} from "../../contracts/utils/Allowlist.sol";

import "forge-std/Script.sol";

contract DeployAllowlist is Script {
    address public owner;

    function setUp() public {
        if (block.chainid == 31337) {
            // todo: replace 31337 by forge constant
            owner = vm.envAddress("A1");
        } else if (block.chainid == 80001) {
            owner = 0x5D45D9C907B26EdE7848Bb9BdD4D08308983d613;
        } else {
            revert("invalid chainid");
        }
        console.log("setUp -- done");
    }

    function run() public {
        vm.startBroadcast(vm.envUint("PVK_A1"));

        address allowlistImpl = address(new Allowlist());
        IHubRegistry hubRegistry = IHubRegistry(0x3d299cA87A62bd0fB005e6e7b081e794c15456DA);
        hubRegistry.setAllowlistAddress(allowlistImpl);
    }
}
