//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IHub} from "../contracts/hub/interfaces/IHub.sol";
import {IAutID} from "../contracts/autid/IAutID.sol";
import {IHubRegistry} from "../contracts/hub/interfaces/IHubRegistry.sol";
import {IGlobalParameters} from "../contracts/globalParameters/IGlobalParameters.sol";
import {Hub} from "../contracts/hub/Hub.sol";
import {AutID} from "../contracts/autid/AutID.sol";
import {HubRegistry} from "../contracts/hub/HubRegistry.sol";
import {GlobalParameters} from "../contracts/globalParameters/GlobalParameters.sol";
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
    address public initialContributionManager;
    uint256 public privateKey;
    bool public deploying;

    // state variables
    address membershipImplementation;
    address participationImplementation;
    address taskFactoryImplementation;
    address taskManagerImplementation;

    AutID public autId;
    HubRegistry public hubRegistry;
    HubDomainsRegistry public hubDomainsRegistry;
    TaskRegistry public taskRegistry;
    GlobalParameters public globalParameters;

    struct TNamedAddress {
        address target;
        string name;
    }

    function setOwner(address _owner) public {
        owner = _owner;
    }

    function setUp() public {
        if (block.chainid == 137) {
            owner = vm.envAddress("MAINNET_OWNER_ADDRESS");
            initialContributionManager = vm.envAddress("MAINNET_INITIAL_CONTRIBUTION_MANAGER");
            privateKey = vm.envUint("MAINNET_PRIVATE_KEY");
        } else if (block.chainid == 80002) {
            owner = vm.envAddress("TESTNET_OWNER_ADDRESS");
            initialContributionManager = vm.envAddress("TESTNET_INITIAL_CONTRIBUTION_MANAGER");
            privateKey = vm.envUint("TESTNET_PRIVATE_KEY");
        } else {
            // testing
            owner = address(123456);
            initialContributionManager = address(11111111);
            privateKey = 567890;
        }
        console.log("setUp -- done");

        deploying = true;
        vm.startBroadcast(privateKey);
    }

    function run() public {
        address trustedForwarder = address(new TrustedForwarder());

        // Deploy AutID
        autId = deployAutId(trustedForwarder, vm.addr(privateKey));
        hubDomainsRegistry = deployHubDomainsRegistry(owner);
        taskRegistry = deployTaskRegistry(owner);
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
            _globalParametersAddress: address(globalParameters),
            _initialContributionManager: initialContributionManager,
            _membershipImplementation: membershipImplementation,
            _participationImplementation: participationImplementation,
            _taskFactoryImplementation: taskFactoryImplementation,
            _taskManagerImplementation: taskManagerImplementation
        });

        // set hubRegistry to autId and transfer ownership
        autId.setHubRegistry(address(hubRegistry));
        autId.transferOwnership(owner);

        // init hubDomainsRegistry now that hubRegistry is deployed
        hubDomainsRegistry.initialize(address(hubRegistry), "Hub Domains Registry", "HDR");

        // other inits
        taskRegistry.initialize();

        // Setup initial tasks
        Task[] memory tasks = new Task[](3);
        // open tasks
        tasks[0] = Task({
            uri: "ipfs://QmScDABgjA3MuiEDsLUDMpfe8cAKL1FgtSzLnGJVUF54Nx"
        });
        // quiz tasks
        tasks[1] = Task({
            uri: "ipfs://QmQZ2wXMsie8EGpbWk9GsRWQUj6JrJuBo7o3xCmnmZVWB7"
        });
        // join discord tasks
        tasks[2] = Task({
            uri: "ipfs://QmQnvc22SuY6x7qg1ujLFCg3E3QvrgfEEjam7rAbd69Rgu"
        });
        // polls
        // tasks[3] = Task({
        //     uri: "ipfs://QmQnvc22SuY6x7qg1ujLFCg3E3QvrgfEEjam7rAbd69Rgu"
        // });
        // // gathering tasks
        // tasks[4] = Task({
        //     uri: "ipfs://QmQnvc22SuY6x7qg1ujLFCg3E3QvrgfEEjam7rAbd69Rgu"
        // });
        taskRegistry.registerTasks(tasks);

        // todo: convert to helper function
        if (deploying) {
            string memory filename = "deployments.txt";
            TNamedAddress[5] memory na;
            na[0] = TNamedAddress({name: "globalParametersProxy", target: address(globalParameters)});
            na[1] = TNamedAddress({name: "autIDProxy", target: address(autId)});
            na[2] = TNamedAddress({name: "hubRegistryProxy", target: address(hubRegistry)});
            na[3] = TNamedAddress({name: "hubDomainsRegistry", target: address(hubDomainsRegistry)});
            na[4] = TNamedAddress({name: "taskRegistry", target: address(taskRegistry)});
            vm.writeLine(filename, string.concat(vm.toString(block.chainid), " ", vm.toString(block.timestamp)));
            for (uint256 i = 0; i != na.length; ++i) {
                vm.writeLine(filename, string.concat(vm.toString(i), ". ", na[i].name, ": ", vm.toString(na[i].target)));
            }
            vm.writeLine(filename, "\n");
        }
    }
}

function deployAutId(address _trustedForwarder, address _owner) returns (AutID) {
    address autIdImplementation = address(new AutID(_trustedForwarder));
    AutProxy autIdProxy = new AutProxy(
        autIdImplementation,
        _owner,
        abi.encodeWithSelector(
            AutID.initialize.selector,
            _owner
        )
    );
    return AutID(address(autIdProxy));
}

function deployHubDomainsRegistry(
    address _owner
) returns (HubDomainsRegistry) {
    address hubDomainsRegistryImplementation = address(new HubDomainsRegistry());
    AutProxy hubDomainsRegistryProxy = new AutProxy(
        hubDomainsRegistryImplementation,
        _owner,
        ""
    );
    return HubDomainsRegistry(address(hubDomainsRegistryProxy));
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
    address _globalParametersAddress,
    address _initialContributionManager,
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
                _globalParametersAddress,
                _initialContributionManager,
                _membershipImplementation,
                _participationImplementation,
                _taskFactoryImplementation,
                _taskManagerImplementation
            )
        )
    );
    return HubRegistry(address(hubRegistryProxy));
}