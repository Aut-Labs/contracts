//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {INova} from "../contracts/nova/INova.sol";
import {IAutID} from "../contracts/autid/IAutID.sol";
import {INovaRegistry} from "../contracts/nova/INovaRegistry.sol";
import {IAllowlist} from "../contracts/utils/IAllowlist.sol";
import {IGlobalParameters} from "../contracts/globalParameters/IGlobalParameters.sol";

import {Nova} from "../contracts/nova/Nova.sol";
import {AutID} from "../contracts/autid/AutID.sol";
import {NovaRegistry} from "../contracts/nova/NovaRegistry.sol";
import {Allowlist} from "../contracts/utils/Allowlist.sol";
import {GlobalParameters} from "../contracts/globalParameters/GlobalParameters.sol";
import {PluginRegistry} from "../contracts/pluginRegistry/PluginRegistry.sol";

import {AutProxy} from "../contracts/proxy/AutProxy.sol";
import {TrustedForwarder} from "../contracts/mocks/TrustedForwarder.sol";

import "forge-std/Script.sol";

contract DeployAll is Script {
    address public trustedForwarder;
    address public owner;

    function setUp() public {
        if (block.chainid == 31337) {
            trustedForwarder = address(new TrustedForwarder());
            owner = address(this);
        } else {
            revert("invalid chainid");
        }
        console.log("setUp -- done");
    }

    function run() public {
        vm.startBroadcast(vm.envUint("PVK_A1"));
        address novaImpl = address(new Nova());
        address novaRegistryImpl = address(new NovaRegistry(trustedForwarder));
        address autIdImpl = address(new AutID(trustedForwarder));
        address globalParametersImpl = address(new GlobalParameters());
        address pluginRegistryImpl = address(new PluginRegistry());

        address globalParametersProxy = address(new AutProxy(globalParametersImpl, owner, ""));
        address autIdProxy = address(new AutProxy(
            autIdImpl,
            owner,
            abi.encodeWithSelector(AutID.initialize.selector, owner)
        ));
        address pluginRegistryProxy = address(new AutProxy(
            pluginRegistryImpl,
            owner,
            abi.encodeWithSelector(PluginRegistry.initialize.selector, owner)
        ));
        address novaRegistryProxy = address(new AutProxy(
            novaRegistryImpl,
            owner,
            abi.encodeWithSelector(NovaRegistry.initialize.selector, autIdProxy, novaImpl, pluginRegistryProxy)
        ));

        console.log("run -- done");
    }
}
