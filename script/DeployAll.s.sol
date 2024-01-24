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
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "forge-std/Script.sol";

contract DeployAll is Script {
    address public trustedForwarder;
    address public owner;

    struct TNamedAddress {
        address target;
        string name;
    }

    function setUp() public {
        if (block.chainid == 31337) { // todo: replace 31337 by forge constant
            trustedForwarder = address(new TrustedForwarder());
            owner = address(this);
        } else if (block.chainid == 80001) {
            trustedForwarder = 0x69015912AA33720b842dCD6aC059Ed623F28d9f7;
            owner = 0x5D45D9C907B26EdE7848Bb9BdD4D08308983d613;
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
            abi.encodeWithSelector(AutID.initialize.selector, address(this))
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

        IAutID(autIdProxy).setNovaRegistry(novaRegistryProxy);
        OwnableUpgradeable(autIdProxy).transferOwnership(owner);


        // todo: convert to helper function
        string memory filename = "deployments.txt";
        TNamedAddress[4] memory na;
        na[0] = TNamedAddress({name: "globalParametersProxy", target: globalParametersProxy});
        na[1] = TNamedAddress({name: "autIDProxy", target: autIdProxy});
        na[2] = TNamedAddress({name: "novaRegistryProxy", target: novaRegistryProxy});
        na[3] = TNamedAddress({name: "pluginRegistryProxy", target: pluginRegistryProxy});
        vm.writeLine(filename, string.concat(vm.toString(block.chainid), " ", vm.toString(block.timestamp)));
        for (uint i = 0; i != na.length; ++i) {
            vm.writeLine(filename, string.concat(
                vm.toString(i),
                ". ",
                na[i].name,
                ": ",
                vm.toString(na[i].target)
            ));
        }
        vm.writeLine(filename, "\n");

    }
}
