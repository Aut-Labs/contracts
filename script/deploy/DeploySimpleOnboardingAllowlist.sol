//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IAllowlist} from "../../contracts/utils/IAllowlist.sol";
import {IHubRegistry} from "../../contracts/hub/IHubRegistry.sol";

import {SimpleAllowlistOnboarding} from "../../contracts/onboarding/SimpleAllowlistOnboarding.sol";
import {BasicOnboarding} from "../../contracts/onboarding/BasicOnboarding.sol";

import "forge-std/Script.sol";

contract DeploySimpleAllowlistOnboarding is Script {
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

        address onboardingRole1 = address(new SimpleAllowlistOnboarding(owner));
        address onboardingRole2 = address(new SimpleAllowlistOnboarding(owner));
        address onboardingRole3 = address(new SimpleAllowlistOnboarding(owner));

        address[] memory addresses = new address[](3);
        addresses[0] = onboardingRole1;
        addresses[1] = onboardingRole2;
        addresses[2] = onboardingRole3;
        address basicOnboarding = address(new BasicOnboarding(addresses));
    }
}
