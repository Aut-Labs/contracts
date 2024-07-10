//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {INova} from "../contracts/nova/INova.sol";
import {IAutID} from "../contracts/autid/IAutID.sol";
import {INovaRegistry} from "../contracts/nova/INovaRegistry.sol";
import {IAllowlist} from "../contracts/utils/IAllowlist.sol";
import {IGlobalParametersAlpha} from "../contracts/globalParameters/IGlobalParametersAlpha.sol";
import {SimpleAllowlistOnboarding} from "../contracts/onboarding/SimpleAllowlistOnboarding.sol";
import {BasicOnboarding} from "../contracts/onboarding/BasicOnboarding.sol";
import {Nova} from "../contracts/nova/Nova.sol";
import {AutID} from "../contracts/autid/AutID.sol";
import {NovaRegistry} from "../contracts/nova/NovaRegistry.sol";
import {Allowlist} from "../contracts/utils/Allowlist.sol";
import {GlobalParametersAlpha} from "../contracts/globalParameters/GlobalParametersAlpha.sol";
import {PluginRegistry} from "../contracts/pluginRegistry/PluginRegistry.sol";
import {HubDomainsRegistry} from "../contracts/hubContracts/HubDomainsRegistry.sol";
import {AutProxy} from "../contracts/proxy/AutProxy.sol";
import {TrustedForwarder} from "../contracts/mocks/TrustedForwarder.sol";

import "forge-std/Script.sol";

contract DeployAll is Script {
    address public trustedForwarder;
    address public owner;
    uint256 public privateKey;

    struct TNamedAddress {
        address target;
        string name;
    }

    function setUp() public {
        if (block.chainid == 137) {
            trustedForwarder = address(new TrustedForwarder());
            owner = vm.envAddress("MAINNET_OWNER_ADDRESS");
            privateKey = vm.envUint("MAINNET_PRIVATE_KEY");
        } else if (block.chainid == 80002) {
            trustedForwarder = address(new TrustedForwarder());
            owner = vm.envAddress("TESTNET_OWNER_ADDRESS");
            privateKey = vm.envUint("TESTNET_PRIVATE_KEY");
        } else {
            revert("invalid chainid");
        }
        console.log("setUp -- done");
    }

    function run() public {
        vm.startBroadcast(privateKey);

        address novaImpl = address(new Nova());
        address novaRegistryImpl = address(new NovaRegistry(trustedForwarder));
        address autIdImpl = address(new AutID(trustedForwarder));
        address globalParametersImpl = address(new GlobalParametersAlpha());
        address pluginRegistryImpl = address(new PluginRegistry());

        address hubDomainsRegistry = address(new HubDomainsRegistry(novaRegistryImpl));

        address globalParametersProxy = address(new AutProxy(globalParametersImpl, owner, ""));
        address autIdProxy =
            address(new AutProxy(autIdImpl, owner, abi.encodeWithSelector(AutID.initialize.selector, owner)));
        address pluginRegistryProxy = address(
            new AutProxy(pluginRegistryImpl, owner, abi.encodeWithSelector(PluginRegistry.initialize.selector, owner))
        );
        address novaRegistryProxy = address(
            new AutProxy(
                novaRegistryImpl,
                owner,
                abi.encodeWithSelector(NovaRegistry.initialize.selector, autIdProxy, novaImpl, pluginRegistryProxy, hubDomainsRegistry)
            )
        );

        IAutID(autIdProxy).setNovaRegistry(novaRegistryProxy);
        address allowlistImpl = address(new Allowlist());
        INovaRegistry(novaRegistryProxy).setAllowlistAddress(allowlistImpl);
        console.log("run -- done");

        address onboardingRole1 = address(new SimpleAllowlistOnboarding(owner));
        address onboardingRole2 = address(new SimpleAllowlistOnboarding(owner));
        address onboardingRole3 = address(new SimpleAllowlistOnboarding(owner));

        address[] memory addresses = new address[](3);
        addresses[0] = onboardingRole1;
        addresses[1] = onboardingRole2;
        addresses[2] = onboardingRole3;
        address basicOnboarding = address(new BasicOnboarding(addresses));

        // todo: convert to helper function
        string memory filename = "deployments.txt";
        TNamedAddress[10] memory na;
        na[0] = TNamedAddress({name: "globalParametersProxy", target: globalParametersProxy});
        na[1] = TNamedAddress({name: "autIDProxy", target: autIdProxy});
        na[2] = TNamedAddress({name: "novaRegistryProxy", target: novaRegistryProxy});
        na[3] = TNamedAddress({name: "pluginRegistryProxy", target: pluginRegistryProxy});
        na[4] = TNamedAddress({name: "allowlist", target: allowlistImpl});
        na[5] = TNamedAddress({name: "basicOnboarding", target: basicOnboarding});
        na[6] = TNamedAddress({name: "onboardingRole1", target: onboardingRole1});
        na[7] = TNamedAddress({name: "onboardingRole2", target: onboardingRole2});
        na[8] = TNamedAddress({name: "onboardingRole3", target: onboardingRole3});
        na[9] = TNamedAddress({name: "hubDomainsRegistry", target: hubDomainsRegistry});
        vm.writeLine(filename, string.concat(vm.toString(block.chainid), " ", vm.toString(block.timestamp)));
        for (uint256 i = 0; i != na.length; ++i) {
            vm.writeLine(filename, string.concat(vm.toString(i), ". ", na[i].name, ": ", vm.toString(na[i].target)));
        }
        vm.writeLine(filename, "\n");
    }
}
