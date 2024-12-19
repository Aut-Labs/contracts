//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IHub} from "../contracts/hub/interfaces/IHub.sol";
import {IAutID} from "../contracts/autid/IAutID.sol";
import {IHubRegistry} from "../contracts/hub/interfaces/IHubRegistry.sol";
import {IGlobalParameters} from "../contracts/globalParameters/IGlobalParameters.sol";
import {IInteractionFactory} from "../contracts/interaction/IInteractionFactory.sol";
import {Hub} from "../contracts/hub/Hub.sol";
import {AutID} from "../contracts/autid/AutID.sol";
import {HubRegistry} from "../contracts/hub/HubRegistry.sol";
import {GlobalParameters} from "../contracts/globalParameters/GlobalParameters.sol";
import {HubDomainsRegistry} from "../contracts/hub/HubDomainsRegistry.sol";
import {AutProxy} from "../contracts/proxy/AutProxy.sol";
import {TrustedForwarder} from "../contracts/mocks/TrustedForwarder.sol";
import {Membership} from "../contracts/membership/Membership.sol";
import {ParticipationScore} from "../contracts/participationScore/ParticipationScore.sol";
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
    
    // TODO: convert to contract with contracts above, deploy
    IInteractionFactory public interactionFactory;

    struct TNamedAddress {
        address target;
        string name;
    }

    function version() public pure returns (uint256 major, uint256 minor, uint256 patch) {
        return (0, 1, 1);
    }

    function setOwner(address _owner) public {
        owner = _owner;
    }

    function setUp() public {
        if (block.chainid == 137) {
            owner = vm.envAddress("MAINNET_OWNER_ADDRESS");
            initialContributionManager = vm.envAddress("MAINNET_INITIAL_CONTRIBUTION_MANAGER");
            privateKey = vm.envUint("MAINNET_PRIVATE_KEY");
            deploying = true;
        } else if (block.chainid == 80002) {
            owner = vm.envAddress("TESTNET_OWNER_ADDRESS");
            initialContributionManager = vm.envAddress("TESTNET_INITIAL_CONTRIBUTION_MANAGER");
            privateKey = vm.envUint("TESTNET_PRIVATE_KEY");
            deploying = true;
        } else {
            // testing
            privateKey = 567890;
            owner = vm.addr(privateKey);
            initialContributionManager = address(11111111);
        }
        console.log("setUp -- done");

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
        taskRegistry.initialize(address(interactionFactory));
        if (deploying) {
            taskRegistry.setApproved(owner);
        }

        // Setup initial tasks
        Task[] memory tasks = new Task[](11);
        // open tasks
        tasks[0] = Task({
            uri: "ipfs://QmaDxYAaMhEbz3dH2N9Lz1RRdAXb3Sre5fqCvgsmKCtJvC",
            interactionId: 0
        });
        // quiz tasks
        tasks[1] = Task({
            uri: "ipfs://QmbnM1ZRjZ2X2Fc6zRm7jsZeTWvZSMjJDc6h3nct7gbAMm",
            interactionId: 0
        });
        // join discord tasks
        tasks[2] = Task({
            uri: "ipfs://QmTe4qYncbW86vgYRvcTTP23sYY9yopYQMwLWh1GKYFmuR",
            interactionId: 0
        });
        // [discord] polls
        tasks[3] = Task({
            uri: "ipfs://QmRdkW4jh55oVhPbNLMRcXZ7KHhcPDd82bfqrkDcGTC8Me",
            interactionId: 0
        });
        // [discord] gathering
        tasks[4] = Task({
            uri: "ipfs://Qme7jXteFKAiSaByMf31cZZgCV2yjGaQcybLS1PmoPCKc2",
            interactionId: 0
        });
        // [github] commit
        tasks[5] = Task({
            uri: "ipfs://Qme9S8rCPEYmJraCNWUdBT2Nc2FSSHtjAeSmcX1RT6EmGg",
            interactionId: 0
        });
        // [github] open pr
        tasks[6] = Task({
            uri: "ipfs://QmPksTgWNfY9bnfHxrVNmPzMBW19ZZRChouYQACEcBVtK5",
            interactionId: 0
        });
        // [twitter] comment
        tasks[7] = Task({
            uri: "ipfs://Qmd28t4X22F54qihKapgaq9d4Sbx4u4rxhWhEozimxfDiQ",
            interactionId: 0
        });
        // [twitter] follow
        tasks[8] = Task({
            uri: "ipfs://QmR3hzxeR5uKiMhQFL4PPB8eqNsoZxAjJ4KNirjiNBF5a7",
            interactionId: 0
        });
        // [twitter] like
        tasks[9] = Task({
            uri: "ipfs://QmNepwgZnQ46AjWCDuBVJCb7ozPfXzWtVZx26PSgwVHzPA",
            interactionId: 0
        });
        // [twitter] retweet
        tasks[10] = Task({
            uri: "ipfs://QmaRRTN1z5SkNzJE1VRQJU3w4RovLHi4Q2yyNy42eMzYsH",
            interactionId: 0
        });
        taskRegistry.registerTasks(tasks);

        // todo: convert to helper function
        if (deploying) {
            string memory filename = "deployments.txt";
            TNamedAddress[5] memory na;
            na[0] = TNamedAddress({name: "globalParameters", target: address(globalParameters)});
            na[1] = TNamedAddress({name: "autID", target: address(autId)});
            na[2] = TNamedAddress({name: "hubRegistry", target: address(hubRegistry)});
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
    participationImplementation = address(new ParticipationScore());
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