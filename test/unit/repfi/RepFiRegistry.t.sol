// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../../BaseTest.sol";

contract RepFiRegistryTest is BaseTest {
    address public plugin = makeAddr("plugin");

    function setUp() public override {
        super.setUp();
    }

    function test_registerPluginNoAccess() public {
        vm.expectRevert();
        vm.prank(alice);
        utilsRegistry.registerPlugin(address(plugin), "test plugin");
    }

    function test_registerPluginZeroAddress() public {
        vm.expectRevert("contractAddress must be a valid address");
        utilsRegistry.registerPlugin(address(0), "test plugin");
    }

    function test_registerPluginSuccess() public {
        utilsRegistry.registerPlugin(address(plugin), "test plugin");
    }

    function test_registerPluginTwiceFail() public {
        utilsRegistry.registerPlugin(address(plugin), "test plugin");

        vm.expectRevert("plugin is already registered");
        utilsRegistry.registerPlugin(address(plugin), "test plugin");
        assertEq(utilsRegistry.isPlugin(address(plugin)), true);
    }

    function test_removePluginZeroAddress() public {
        vm.expectRevert("contractAddress must be a valid address");
        utilsRegistry.removePlugin(address(0));
    }

    function test_removePluginUnknown() public {
        vm.expectRevert("plugin does not exist");
        utilsRegistry.removePlugin(address(plugin));
    }

    function test_getPluginDescription() public {
        utilsRegistry.registerPlugin(address(plugin), "test plugin");
        assertEq(utilsRegistry.getPluginDescription(address(plugin)), "test plugin");
    }
}
