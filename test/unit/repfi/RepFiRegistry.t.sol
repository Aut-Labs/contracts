// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../../BaseTest.sol";

contract RepFiRegistryTest is BaseTest {
    address public plugin = makeAddr("plugin");

    function setUp() public override {
        super.setUp();
    }

    function test_registerPluginNoAccess() public {
        vm.expectRevert();
        vm.prank(alice);
        repFiRegistry.registerPlugin(address(plugin), "test plugin");
    }

    function test_registerPluginZeroAddress() public {
        vm.expectRevert("contractAddress must be a valid address");
        repFiRegistry.registerPlugin(address(0), "test plugin");
    }

    function test_registerPluginSuccess() public {
        repFiRegistry.registerPlugin(address(plugin), "test plugin");
    }

    function test_registerPluginTwiceFail() public {
        repFiRegistry.registerPlugin(address(plugin), "test plugin");

        vm.expectRevert("plugin is already registered");
        repFiRegistry.registerPlugin(address(plugin), "test plugin");
        assertEq(repFiRegistry.isPlugin(address(plugin)), true);
    }

    function test_removePluginZeroAddress() public {
        vm.expectRevert("contractAddress must be a valid address");
        repFiRegistry.removePlugin(address(0));
    }

    function test_removePluginUnknown() public {
        vm.expectRevert("plugin does not exist");
        repFiRegistry.removePlugin(address(plugin));
    }

    function test_getPluginDescription() public {
        repFiRegistry.registerPlugin(address(plugin), "test plugin");
        assertEq(repFiRegistry.getPluginDescription(address(plugin)), "test plugin");
    }
}
