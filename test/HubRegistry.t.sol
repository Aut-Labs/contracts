// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console2.sol";

import {HubRegistryDeployHelper} from "./helpers/DeployHelpers.sol";

contract HubRegistryTest is Test, HubRegistryDeployHelper {
    function owner() internal view override returns (address) {
        return address(this);
    }

    function trustedForwarder() internal view override returns (address) {
        return owner();
    }

    function setUp() public {
        deploy();
    }

    function testFail_hubRegistryEmpty() public {
        assertEq(address(hubRegistry()), address(0));
    }

    function testFail_autIDEmpty() public {
        assertEq(address(autID()), address(0));
    }

    function testFail_pluginRegistryEmpty() public {
        assertEq(address(pluginRegistry()), address(0));
    }
}
