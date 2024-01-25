// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {NovaRegistryDeployHelper} from "./DeployHelpers.sol";
import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "forge-std/console2.sol";


contract NovaRegistryTest is Test, NovaRegistryDeployHelper {
    function owner() internal override returns(address) {
        return address(this);
    }

    function trustedForwarder() internal override returns(address) {
        return owner();
    }

    function setUp() public {
        deploy();
    }

    function testFail_novaRegistry() public {
        assertEq(address(novaRegistry()), address(0));
    }

    function testFail_autID() public {
        assertEq(address(autID()), address(0));
    }

    function testFaild_pluginRegistryEmpty() public {
        assertEq(address(pluginRegistry()), address(0));
        console2.log(vm.toString(address(pluginRegistry())));
    }
}
