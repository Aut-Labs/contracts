//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IHub} from "../contracts/hub/IHub.sol";
import {IAutID} from "../contracts/autid/IAutID.sol";
import {IHubRegistry} from "../contracts/hub/IHubRegistry.sol";
import {IAllowlist} from "../contracts/utils/IAllowlist.sol";
import {IGlobalParametersAlpha} from "../contracts/globalParameters/IGlobalParametersAlpha.sol";
import {SimpleAllowlistOnboarding} from "../contracts/onboarding/SimpleAllowlistOnboarding.sol";
import {BasicOnboarding} from "../contracts/onboarding/BasicOnboarding.sol";
import {Hub} from "../contracts/hub/Hub.sol";
import {AutID} from "../contracts/autid/AutID.sol";
import {HubRegistry} from "../contracts/hub/HubRegistry.sol";
import {InteractionRegistry} from "../contracts/interactions/InteractionRegistry.sol";
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
    PluginRegistry pluginRegistry;
    HubRegistry public novaRegistry;
    HubDomainsRegistry public hubDomainsRegistry;
    InteractionRegistry public interactionRegistry;
    GlobalParametersAlpha public globalParameters;
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
        autId = deployAutId(trustedForwarder, owner);
        pluginRegistry = deployPluginRegistry(owner);
        hubDomainsRegistry = deployHubDomainsRegistry(owner);
        interactionRegistry = deployInteractionRegistry(owner);
        globalParameters = deployGlobalParameters(owner);
        novaRegistry = deployHubRegistry({
            _trustedForwarder: trustedForwarder,
            _owner: owner,
            _autIdAddress: address(autId),
            _pluginRegistryAddress: address(pluginRegistry),
            _hubDomainsRegistryAddress: address(hubDomainsRegistry),
            _globalParametersAddress: address(globalParameters)
        });
        basicOnboarding = deployBasicOnboarding(owner);

        // set novaRegistry to autId (assumes msg.sender == owner [TODO: change this])
        // autId.setHubRegistry(address(novaRegistry));

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
            na[5] = TNamedAddress({name: "basicOnboarding", target: address(basicOnboarding)});
            na[9] = TNamedAddress({name: "hubDomainsRegistry", target: address(hubDomainsRegistry)});
            vm.writeLine(filename, string.concat(vm.toString(block.chainid), " ", vm.toString(block.timestamp)));
            for (uint256 i = 0; i != na.length; ++i) {
                vm.writeLine(filename, string.concat(vm.toString(i), ". ", na[i].name, ": ", vm.toString(na[i].target)));
            }
            vm.writeLine(filename, "\n");
        }
    }
}

function deployAutId(address _trustedForwarder, address _owner) returns (AutID) {
    AutID autIdImplementation = new AutID(_trustedForwarder);
    AutProxy autIdProxy = new AutProxy(
        address(autIdImplementation),
        _owner,
        abi.encodeWithSelector(
            AutID.initialize.selector,
            msg.sender
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
    HubDomainsRegistry hubDomainsRegistry = new HubDomainsRegistry(address(1)); // TODO
    return hubDomainsRegistry;
}

function deployInteractionRegistry(address _owner) returns (InteractionRegistry) {
    InteractionRegistry interactionRegistry = new InteractionRegistry(_owner);
    return interactionRegistry;
}

function deployGlobalParameters(address _owner) returns (GlobalParametersAlpha) {
    GlobalParametersAlpha globalParametersImplementation = new GlobalParametersAlpha();
    AutProxy globalParametersProxy = new AutProxy(
        address(globalParametersImplementation),
        _owner,
        ""
    );
    return GlobalParametersAlpha(address(globalParametersProxy));
}

function deployHubRegistry(
    address _trustedForwarder,
    address _owner,
    address _autIdAddress,
    address _pluginRegistryAddress,
    address _hubDomainsRegistryAddress,
    address _globalParametersAddress
) returns (HubRegistry) {
    address novaImplementation = address(new Hub());
    address novaRegistryImplementation = address(new HubRegistry(_trustedForwarder));
    AutProxy novaRegistryProxy = new AutProxy(
        novaRegistryImplementation,
        _owner,
        abi.encodeWithSelector(
            HubRegistry.initialize.selector,
            _autIdAddress,
            novaImplementation,
            _pluginRegistryAddress,
            _hubDomainsRegistryAddress,
            _globalParametersAddress
        )
    );
    return HubRegistry(address(novaRegistryProxy));
}

function deployBasicOnboarding(address _owner) returns (BasicOnboarding) {
    address onboardingRole1 = address(new SimpleAllowlistOnboarding(_owner));
    address onboardingRole2 = address(new SimpleAllowlistOnboarding(_owner));
    address onboardingRole3 = address(new SimpleAllowlistOnboarding(_owner));

    address[] memory addresses = new address[](3);
    addresses[0] = onboardingRole1;
    addresses[1] = onboardingRole2;
    addresses[2] = onboardingRole3;
    BasicOnboarding basicOnboarding = new BasicOnboarding(addresses);

    return basicOnboarding;
}