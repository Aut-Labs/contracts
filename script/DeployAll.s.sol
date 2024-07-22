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
    address public owner;
    uint256 public privateKey;
    bool public deploying;

    // state variables
    AutID public autId;
    NovaRegistry public novaRegistry;
    GlobalParametersAlpha public globalParameters;
    HubDomainsRegistry public hubDomainsRegistry;
    BasicOnboarding public basicOnboarding;

    struct TNamedAddress {
        address target;
        string name;
    }

    function setUpTest(address _owner) public {
        owner = _owner;
    }

    function setUp() public {
        if (block.chainid == 137) {
            owner = vm.envAddress("MAINNET_OWNER_ADDRESS");
            privateKey = vm.envUint("MAINNET_PRIVATE_KEY");
        } else if (block.chainid == 80002) {
            owner = vm.envAddress("TESTNET_OWNER_ADDRESS");
            privateKey = vm.envUint("TESTNET_PRIVATE_KEY");
        } else {
            revert("invalid chainid");
        }
        console.log("setUp -- done");

        deploying = true;
        vm.startBroadcast(privateKey);
    }

    function run() public {
        address trustedForwarder = address(new TrustedForwarder());

        // Deploy AutID
        autId = deployAutId(owner);
        pluginRegistry = deployPluginRegistry(owner);
        hubDomainsRegistry = deployHubDomainsRegistry(owner);
        novaRegistry = deployNovaRegistry({
            _owner: owner,
            _autIdAddress: address(autId),
            _pluginRegistryAddress: address(pluginRegistry),
            _hubDomainsRegistryAddress: address(hubDomainsRegistry)
        });
        globalParameters = deployGlobalParameters(owner);
        basicOnboarding = deployBasicOnboarding();

        // set novaRegistry to autId (assumes msg.sender == owner [TODO: change this])
        autId.setNovaRegistry(address(novaRegistry));

        // Create and set the allowlist
        Allowlist allowlist = new Allowlist();
        novaRegistry.setAllowlistAddress(address(allowlist));

        // todo: convert to helper function
        if (deploying) {
            string memory filename = "deployments.txt";
            TNamedAddress[10] memory na;
            na[0] = TNamedAddress({name: "globalParametersProxy", target: address(globalParameters)});
            na[1] = TNamedAddress({name: "autIDProxy", target: address(autId)});
            na[2] = TNamedAddress({name: "novaRegistryProxy", target: address(novaRegistry)});
            na[3] = TNamedAddress({name: "pluginRegistryProxy", target: address(pluginRegistry)});
            na[4] = TNamedAddress({name: "allowlist", target: address(allowlist)});
            na[5] = TNamedAddress({name: "basicOnboarding", target: basicOnboarding});
            na[9] = TNamedAddress({name: "hubDomainsRegistry", target: address(hubDomainsRegistry)});
            vm.writeLine(filename, string.concat(vm.toString(block.chainid), " ", vm.toString(block.timestamp)));
            for (uint256 i = 0; i != na.length; ++i) {
                vm.writeLine(filename, string.concat(vm.toString(i), ". ", na[i].name, ": ", vm.toString(na[i].target)));
            }
            vm.writeLine(filename, "\n");
        }
    }
}

function deployAutId(address _owner) returns (AutID) {
    AutID autIdImplementation = new AutID(trustedForwarder);
    AutProxy autIdProxy = new AutProxy(
        address(autIdImplementation),
        _owner,
        abi.encodeWithSelector(
            AutID.initialize.selector,
            _owner
        )
    );
    return AutID(address(autIdProxy));
}

function deployPluginRegistry(address _owner) returns (PluginRegistry) {
    PluginRegistry pluginRegistryImplementation = new PluginRegistry();
    AutProxy pluginRegistryProxy = new AutProxy(
        address(pluginRegistryImplementation),
        _owner,
        abi.encodeWithSelector(
            PluginRegistry.initialize.selector,
            _owner
        )
    );
    return PluginRegistry(address(pluginRegistryProxy));
}

function deployHubDomainsRegistry(
    address _owner
) returns (HubDomainsRegistry) {
    // address hubDomainsRegistry = address(new HubDomainsRegistry(novaImpl));
    HubDomainsRegistry hubDomainsRegistry = new HubDomainsRegistry(address(0)); // TODO
    return hubDomainsRegistry;
}

function deployGlobalParameters(address _owner) returns (GlobalParametersAlpha) {
    GlobalParametersAlpha globalParametersImplementation = new GlobalParametersAlpha();
    AutProxy globalParametersProxy = new AutProxy(
        globalParametersImplementation,
        _owner,
        ""
    );
    return GlobalParametersAlpha(address(globalParametersProxy));
}

function deployNovaRegistry(
    address _owner
    address _autIdAddress,
    address _pluginRegistryAddress,
    address _hubDomainsRegistryAddress
) returns (NovaRegistry) {
    address novaImplementation = address(new Nova());
    address novaRegistryImplementation = address(new NovaRegistry(trustedForwarder));
    AutProxy novaRegistryProxy = new AutProxy(
        novaRegistryImpl,
        _owner,
        abi.encodeWithSelector(
            NovaRegistry.initialize.selector,
            autIdProxy,
            novaImpl,
            pluginRegistryProxy,
            hubDomainsRegistry
        )
    );
}

function deployBasicOnboarding() returns (BasicOnboarding) {
    address onboardingRole1 = address(new SimpleAllowlistOnboarding(owner));
    address onboardingRole2 = address(new SimpleAllowlistOnboarding(owner));
    address onboardingRole3 = address(new SimpleAllowlistOnboarding(owner));

    address[] memory addresses = new address[](3);
    addresses[0] = onboardingRole1;
    addresses[1] = onboardingRole2;
    addresses[2] = onboardingRole3;
    BasicOnboarding basicOnboarding = new BasicOnboarding(addresses);

    return basicOnboarding;
}