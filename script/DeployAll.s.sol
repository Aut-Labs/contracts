//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IHub} from "../contracts/hub/interfaces/IHub.sol";
import {IAutID} from "../contracts/autid/IAutID.sol";
import {IHubRegistry} from "../contracts/hub/interfaces/IHubRegistry.sol";
import {IAllowlist} from "../contracts/utils/IAllowlist.sol";
import {IGlobalParameters} from "../contracts/globalParameters/IGlobalParameters.sol";
import {SimpleAllowlistOnboarding} from "../contracts/onboarding/SimpleAllowlistOnboarding.sol";
import {BasicOnboarding} from "../contracts/onboarding/BasicOnboarding.sol";
import {Hub} from "../contracts/hub/Hub.sol";
import {AutID} from "../contracts/autid/AutID.sol";
import {HubRegistry} from "../contracts/hub/HubRegistry.sol";
import {InteractionRegistry} from "../contracts/interactions/InteractionRegistry.sol";
import {Allowlist} from "../contracts/utils/Allowlist.sol";
import {GlobalParameters} from "../contracts/globalParameters/GlobalParameters.sol";
import {PluginRegistry} from "../contracts/pluginRegistry/PluginRegistry.sol";
import {HubDomainsRegistry} from "../contracts/hub/HubDomainsRegistry.sol";
import {AutProxy} from "../contracts/proxy/AutProxy.sol";
import {TrustedForwarder} from "../contracts/mocks/TrustedForwarder.sol";
import {Membership} from "../contracts/membership/Membership.sol";
import {Participation} from "../contracts/participation/Participation.sol";
import {Task, TaskRegistry} from "../contracts/tasks/TaskRegistry.sol";
import {TaskFactory} from "../contracts/tasks/TaskFactory.sol";
import {TaskManager} from "../contracts/tasks/TaskManager.sol";


import "forge-std/Script.sol";

contract DeployAll is Script {
    address public owner;
    uint256 public privateKey;
    bool public deploying;

    // state variables
    address membershipImplementation;
    address participationImplementation;
    address taskFactoryImplementation;
    address taskManagerImplementation;

    AutID public autId;
    PluginRegistry pluginRegistry;
    HubRegistry public hubRegistry;
    HubDomainsRegistry public hubDomainsRegistry;
    TaskRegistry public taskRegistry;
    InteractionRegistry public interactionRegistry;
    GlobalParameters public globalParameters;
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
            // revert("invalid chainid");
            owner = vm.envAddress("OWNER");
            privateKey = vm.envUint("PRIVATE_KEY");
        }
        console.log("setUp -- done");

        deploying = true;
        vm.startBroadcast(privateKey);
    }

    function run() public {
        address trustedForwarder = address(new TrustedForwarder());

        // Deploy AutID
        autId = deployAutId(trustedForwarder, vm.addr(privateKey));
        pluginRegistry = deployPluginRegistry(owner);
        hubDomainsRegistry = deployHubDomainsRegistry(owner);
        taskRegistry = deployTaskRegistry(owner);
        interactionRegistry = deployInteractionRegistry(owner);
        globalParameters = deployGlobalParameters(owner);
        (
            membershipImplementation,
            participationImplementation,
            taskFactoryImplementation,
            taskManagerImplementation
        ) = deployHubDependencyImplementations();
        hubRegistry = deployHubRegistry({
            _trustedForwarder: trustedForwarder,
            _owner: owner,
            _autIdAddress: address(autId),
            _hubDomainsRegistryAddress: address(hubDomainsRegistry),
            _taskRegistryAddress: address(taskRegistry),
            _interactionRegistryAddress: address(interactionRegistry),
            _globalParametersAddress: address(globalParameters),
            _membershipImplementation: membershipImplementation,
            _participationImplementation: participationImplementation,
            _taskFactoryImplementation: taskFactoryImplementation,
            _taskManagerImplementation: taskManagerImplementation
        });
        basicOnboarding = deployBasicOnboarding(owner);

        // set hubRegistry to autId and transfer ownership
        autId.setHubRegistry(address(hubRegistry));
        autId.transferOwnership(owner);

        // Create and set the allowlist
        Allowlist allowlist = new Allowlist();
        hubRegistry.setAllowlistAddress(address(allowlist));

        // Setup initial tasks
        Task[] memory tasks = new Task[](3);
        tasks[0] = Task({
            uri: "ipfs://bafkreia2si4nhqjdxg543z7pp5kchvx4auwm7gn54wftfa2vykfkjc4ppe"
        });
        tasks[1] = Task({
            uri: "ipfs://bafkreihxcz6eytmf6lm5oyqee67jujxepuczl42lw2orlfsw6yds5gm46i"
        });
        tasks[2] = Task({
            uri: "ipfs://bafkreieg7dwphs4554g726kalv5ez22hd55k3bksepa6rrvon6gf4mupey"
        });
        taskRegistry.registerTasks(tasks);

        // todo: convert to helper function
        if (deploying) {
            string memory filename = "deployments.txt";
            TNamedAddress[8] memory na;
            na[0] = TNamedAddress({name: "globalParametersProxy", target: address(globalParameters)});
            na[1] = TNamedAddress({name: "autIDProxy", target: address(autId)});
            na[2] = TNamedAddress({name: "hubRegistryProxy", target: address(hubRegistry)});
            na[3] = TNamedAddress({name: "pluginRegistryProxy", target: address(pluginRegistry)});
            na[4] = TNamedAddress({name: "allowlist", target: address(allowlist)});
            na[5] = TNamedAddress({name: "basicOnboarding", target: address(basicOnboarding)});
            na[6] = TNamedAddress({name: "hubDomainsRegistry", target: address(hubDomainsRegistry)});
            na[7] = TNamedAddress({name: "taskRegistry", target: address(taskRegistry)});
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
    // address hubDomainsRegistry = address(new HubDomainsRegistry(hubImpl));
    HubDomainsRegistry hubDomainsRegistry = new HubDomainsRegistry(_owner);
    return hubDomainsRegistry;
}

function deployTaskRegistry(address _owner) returns (TaskRegistry) {
    address taskRegistryImplementation = address(new TaskRegistry());
    AutProxy taskRegistryProxy = new AutProxy(
        taskRegistryImplementation,
        _owner,
        ""
    );
    return TaskRegistry(address(taskRegistryProxy));
}

function deployInteractionRegistry(address _owner) returns (InteractionRegistry) {
    InteractionRegistry interactionRegistry = new InteractionRegistry(_owner);
    return interactionRegistry;
}

function deployGlobalParameters(address _owner) returns (GlobalParameters) {
    address globalParametersImplementation = address(new GlobalParameters());
    AutProxy globalParametersProxy = new AutProxy(
        globalParametersImplementation,
        _owner,
        ""
    );
    return GlobalParameters(address(globalParametersProxy));
}

function deployHubDependencyImplementations() returns (
    address membershipImplementation,
    address participationImplementation,
    address taskFactoryImplementation,
    address taskManagerImplementation
) {
    membershipImplementation = address(new Membership());
    participationImplementation = address(new Participation());
    taskFactoryImplementation = address(new TaskFactory());
    taskManagerImplementation = address(new TaskManager());
}

function deployHubRegistry(
    address _trustedForwarder,
    address _owner,
    address _autIdAddress,
    address _hubDomainsRegistryAddress,
    address _taskRegistryAddress,
    address _interactionRegistryAddress,
    address _globalParametersAddress,
    address _membershipImplementation,
    address _participationImplementation,
    address _taskFactoryImplementation,
    address _taskManagerImplementation
) returns (HubRegistry) {
    address hubImplementation = address(new Hub());
    address hubRegistryImplementation = address(new HubRegistry(_trustedForwarder));
    AutProxy hubRegistryProxy = new AutProxy(
        hubRegistryImplementation,
        _owner,
        abi.encodeCall(
            IHubRegistry.initialize,
            (
                _autIdAddress,
                hubImplementation,
                _hubDomainsRegistryAddress,
                _taskRegistryAddress,
                _interactionRegistryAddress,
                _globalParametersAddress,
                _membershipImplementation,
                _participationImplementation,
                _taskFactoryImplementation,
                _taskManagerImplementation
            )
        )
    );
    return HubRegistry(address(hubRegistryProxy));
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