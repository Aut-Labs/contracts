//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

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
import {ParticipationScore} from "../contracts/participationScore/ParticipationScore.sol";
import {Task, TaskRegistry} from "../contracts/tasks/TaskRegistry.sol";
import {TaskFactory} from "../contracts/tasks/TaskFactory.sol";
import {TaskManager} from "../contracts/tasks/TaskManager.sol";

import {UtilsRegistry} from "../contracts/repfi/utilsRegistry/UtilsRegistry.sol";
import {Aut} from "../contracts/repfi/token/AUT.sol";
import {CAut} from "../contracts/repfi/token/cAUT.sol";
import {ReputationMining} from "../contracts/repfi/reputationMining/ReputationMining.sol";
import {Distributor} from "../contracts/repfi/token/Distributor.sol";
import {RandomNumberGenerator} from "../contracts/randomNumberGenerator/RandomNumberGenerator.sol";
import {PeerValue} from "../contracts/repfi/peerValue/PeerValue.sol";
import {PeerStaking} from "../contracts/repfi/peerStaking/PeerStaking.sol";

import "forge-std/Script.sol";

contract DeployAll is Script {
    address public owner;
    address public initialContributionManager;
    address public projectMultisig;
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
    UtilsRegistry public utilsRegistry;
    Aut public aut;
    CAut public cAut;
    address public sale;
    address public founderInvestors;
    address public earlyContributors;
    address public airdrop; // merkle
    address public listing; // multisig
    address public kolsAdvisors;
    address public treasury;
    address public profitSharing;
    address public circular;
    address public reputationMiningSafe;
    ReputationMining public reputationMining;
    Distributor public distributor;
    RandomNumberGenerator public randomNumberGenerator;
    PeerValue public peerValue;
    PeerStaking public peerStaking;

    struct TNamedAddress {
        address target;
        string name;
    }

    function version() public pure returns (uint256 major, uint256 minor, uint256 patch) {
        return (0, 1, 1);
    }

    function setOwner(address _owner) public {
        owner = _owner;
        projectMultisig = owner;
    }

    function setUp() public {
        if (block.chainid == 137) {
            owner = vm.envAddress("MAINNET_OWNER_ADDRESS");
            initialContributionManager = vm.envAddress("MAINNET_INITIAL_CONTRIBUTION_MANAGER");
            privateKey = vm.envUint("MAINNET_PRIVATE_KEY");
            deploying = true;
            projectMultisig = vm.envAddress("MAINNET_PROJECT_MULTISIG_ADDRESS");

            // token allocation contracts
            circular = vm.envAddress("MAINNET_CIRCULAR_CONTRACT");
            sale = vm.envAddress("MAINNET_SALE_MULTISIG");
            treasury = vm.envAddress("MAINNET_TREASURY_MULTISIG");
            profitSharing = vm.envAddress("MAINNET_PROFITSHARING_MULTISIG");
            airdrop = vm.envAddress("MAINNET_AIRDROP_MULTISIG");
            listing = vm.envAddress("MAINNET_LISTING_MULTISIG");
            founderInvestors = vm.envAddress("MAINNET_FOUNDER_INVESTORS_MULTISIG");
            earlyContributors = vm.envAddress("MAINNET_EARLY_CONTRIBUTORS_MULTISIG");
            kolsAdvisors = vm.envAddress("MAINNET_KOLS_ADVISORS_MULTISIG");
            reputationMiningSafe = vm.envAddress("MAINNET_REPUTATION_MINING_MULTISIG");
        } else if (block.chainid == 80002) {
            owner = vm.envAddress("TESTNET_OWNER_ADDRESS");
            initialContributionManager = vm.envAddress("TESTNET_INITIAL_CONTRIBUTION_MANAGER");
            privateKey = vm.envUint("TESTNET_PRIVATE_KEY");
            deploying = true;
            projectMultisig = vm.envAddress("TESTNET_PROJECT_MULTISIG_ADDRESS");

            // token allocation contracts
            circular = vm.envAddress("TESTNET_CIRCULAR_CONTRACT");
            sale = vm.envAddress("TESTNET_SALE_MULTISIG");
            treasury = vm.envAddress("TESTNET_TREASURY_MULTISIG");
            profitSharing = vm.envAddress("TESTNET_PROFITSHARING_MULTISIG");
            airdrop = vm.envAddress("TESTNET_AIRDROP_MULTISIG");
            listing = vm.envAddress("TESTNET_LISTING_MULTISIG");
            founderInvestors = vm.envAddress("TESTNET_FOUNDER_INVESTORS_MULTISIG");
            earlyContributors = vm.envAddress("TESTNET_EARLY_CONTRIBUTORS_MULTISIG");
            kolsAdvisors = vm.envAddress("TESTNET_KOLS_ADVISORS_MULTISIG");
            reputationMiningSafe = vm.envAddress("TESTNET_REPUTATION_MINING_MULTISIG");
        } else {
            // testing
            privateKey = 567890;
            owner = vm.addr(privateKey);
            initialContributionManager = address(11111111);

            // token allocation contracts
            circular = makeAddr("circular");
            sale = makeAddr("sale");
            treasury = makeAddr("treasury");
            profitSharing = makeAddr("profitSharing");
            airdrop = makeAddr("airdrop");
            listing = makeAddr("listing");
            founderInvestors = makeAddr("foundersInvestors");
            earlyContributors = makeAddr("earlyContributors");
            kolsAdvisors = makeAddr("kolsAdvisors");
            reputationMiningSafe = makeAddr("reputationMiningSafe");
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
        taskRegistry.initialize();
        if (deploying) {
            taskRegistry.setApproved(owner);
        }

        // Setup initial tasks
        Task[] memory tasks = new Task[](11);
        // open tasks
        tasks[0] = Task({uri: "ipfs://QmaDxYAaMhEbz3dH2N9Lz1RRdAXb3Sre5fqCvgsmKCtJvC"});
        // quiz tasks
        tasks[1] = Task({uri: "ipfs://QmbnM1ZRjZ2X2Fc6zRm7jsZeTWvZSMjJDc6h3nct7gbAMm"});
        // join discord tasks
        tasks[2] = Task({uri: "ipfs://QmTe4qYncbW86vgYRvcTTP23sYY9yopYQMwLWh1GKYFmuR"});
        // [discord] polls
        tasks[3] = Task({uri: "ipfs://QmRdkW4jh55oVhPbNLMRcXZ7KHhcPDd82bfqrkDcGTC8Me"});
        // [discord] gathering
        tasks[4] = Task({uri: "ipfs://Qme7jXteFKAiSaByMf31cZZgCV2yjGaQcybLS1PmoPCKc2"});
        // [github] commit
        tasks[5] = Task({uri: "ipfs://Qme9S8rCPEYmJraCNWUdBT2Nc2FSSHtjAeSmcX1RT6EmGg"});
        // [github] open pr
        tasks[6] = Task({uri: "ipfs://QmPksTgWNfY9bnfHxrVNmPzMBW19ZZRChouYQACEcBVtK5"});
        // [twitter] comment
        tasks[7] = Task({uri: "ipfs://Qmd28t4X22F54qihKapgaq9d4Sbx4u4rxhWhEozimxfDiQ"});
        // [twitter] follow
        tasks[8] = Task({uri: "ipfs://QmR3hzxeR5uKiMhQFL4PPB8eqNsoZxAjJ4KNirjiNBF5a7"});
        // [twitter] like
        tasks[9] = Task({uri: "ipfs://QmNepwgZnQ46AjWCDuBVJCb7ozPfXzWtVZx26PSgwVHzPA"});
        // [twitter] retweet
        tasks[10] = Task({uri: "ipfs://QmaRRTN1z5SkNzJE1VRQJU3w4RovLHi4Q2yyNy42eMzYsH"});
        taskRegistry.registerTasks(tasks);

        utilsRegistry = deployUtilsRegistry(owner);

        // deploy token contracts
        aut = deployAutToken();
        cAut = deployCAutToken(address(owner), address(utilsRegistry));

        randomNumberGenerator = new RandomNumberGenerator();

        // deploy PeerValue
        peerValue = deployPeerValue(randomNumberGenerator);

        // deploy reputationMining
        reputationMining = deployReputationMining(
            owner,
            address(aut),
            address(cAut),
            address(circular),
            address(peerValue),
            address(autId)
        );

        // deploy distributor
        distributor = deployDistributor(
            aut,
            sale,
            reputationMiningSafe,
            airdrop,
            founderInvestors,
            earlyContributors,
            listing,
            treasury,
            kolsAdvisors
        );

        // deploy PeerStaking
        peerStaking = deployPeerStaking(
            owner,
            address(aut),
            address(cAut),
            address(circular),
            address(peerValue),
            address(reputationMining)
        );

        // register aut plugins, more to add later

        vm.stopBroadcast();
        vm.startPrank(owner);
        // give burner role to reputationmining in c-aut
        cAut.grantRole(cAut.BURNER_ROLE(), address(reputationMining));

        // transfer admin role to multisig
        cAut.grantRole(cAut.DEFAULT_ADMIN_ROLE(), projectMultisig);
        cAut.revokeRole(cAut.DEFAULT_ADMIN_ROLE(), owner);

        utilsRegistry.registerPlugin(owner, "Deployer");
        utilsRegistry.registerPlugin(address(distributor), "Distributor");
        utilsRegistry.registerPlugin(address(reputationMining), "ReputationMining");
        utilsRegistry.registerPlugin(address(peerValue), "PeerValue");
        utilsRegistry.registerPlugin(address(peerStaking), "PeerStaking");

        // send c-aut to reputationMining
        cAut.transfer(address(reputationMining), 36000000 ether);

        // remove owner from plugins
        utilsRegistry.removePlugin(owner);

        // transfer ownership to multisig for all contracts that have an owner
        reputationMining.transferOwnership(projectMultisig);
        utilsRegistry.transferOwnership(projectMultisig);
        peerStaking.transferOwnership(projectMultisig);

        vm.stopPrank();

        vm.startBroadcast(privateKey);

        // send tokens to distribution contract
        aut.transfer(address(distributor), 100000000 ether); // 100 million aut tokens

        // distribute tokens
        distributor.distribute();

        if (deploying) {
            string memory filename = "deployments.txt";
            TNamedAddress[24] memory na;
            na[0] = TNamedAddress({name: "globalParameters", target: address(globalParameters)});
            na[1] = TNamedAddress({name: "autID", target: address(autId)});
            na[2] = TNamedAddress({name: "hubRegistry", target: address(hubRegistry)});
            na[3] = TNamedAddress({name: "hubDomainsRegistry", target: address(hubDomainsRegistry)});
            na[4] = TNamedAddress({name: "taskRegistry", target: address(taskRegistry)});
            na[10] = TNamedAddress({name: "utilsRegistry", target: address(utilsRegistry)});
            na[11] = TNamedAddress({name: "aut", target: address(aut)});
            na[12] = TNamedAddress({name: "c-aut", target: address(cAut)});
            na[13] = TNamedAddress({name: "sale", target: address(sale)});
            na[15] = TNamedAddress({name: "founderInvestors", target: address(founderInvestors)});
            na[16] = TNamedAddress({name: "earlyContributors", target: address(earlyContributors)});
            na[17] = TNamedAddress({name: "airdrop", target: address(airdrop)});
            na[18] = TNamedAddress({name: "partners", target: address(listing)});
            na[19] = TNamedAddress({name: "treasury", target: address(treasury)});
            na[20] = TNamedAddress({name: "profitSharing", target: address(profitSharing)});
            na[21] = TNamedAddress({name: "circular", target: address(circular)});
            na[22] = TNamedAddress({name: "reputationMining", target: address(reputationMining)});
            na[23] = TNamedAddress({name: "distributor", target: address(distributor)});

            vm.writeLine(filename, string.concat(vm.toString(block.chainid), " ", vm.toString(block.timestamp)));
            for (uint256 i = 0; i != na.length; ++i) {
                vm.writeLine(
                    filename,
                    string.concat(vm.toString(i), ". ", na[i].name, ": ", vm.toString(na[i].target))
                );
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
        abi.encodeWithSelector(AutID.initialize.selector, _owner)
    );
    return AutID(address(autIdProxy));
}

function deployHubDomainsRegistry(address _owner) returns (HubDomainsRegistry) {
    address hubDomainsRegistryImplementation = address(new HubDomainsRegistry());
    AutProxy hubDomainsRegistryProxy = new AutProxy(hubDomainsRegistryImplementation, _owner, "");
    return HubDomainsRegistry(address(hubDomainsRegistryProxy));
}

function deployTaskRegistry(address _owner) returns (TaskRegistry) {
    address taskRegistryImplementation = address(new TaskRegistry());
    AutProxy taskRegistryProxy = new AutProxy(taskRegistryImplementation, _owner, "");
    return TaskRegistry(address(taskRegistryProxy));
}

function deployGlobalParameters(address _owner) returns (GlobalParameters) {
    address globalParametersImplementation = address(new GlobalParameters());
    AutProxy globalParametersProxy = new AutProxy(globalParametersImplementation, _owner, "");
    return GlobalParameters(address(globalParametersProxy));
}

function deployHubDependencyImplementations()
    returns (
        address membershipImplementation,
        address participationImplementation,
        address taskFactoryImplementation,
        address taskManagerImplementation
    )
{
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

function deployUtilsRegistry(address _owner) returns (UtilsRegistry) {
    UtilsRegistry utilsRegistryImplementation = new UtilsRegistry();
    AutProxy utilsRegistryProxy = new AutProxy(
        address(utilsRegistryImplementation),
        _owner,
        abi.encodeWithSelector(UtilsRegistry.initialize.selector, _owner)
    );
    return UtilsRegistry(address(utilsRegistryProxy));
}

function deployAutToken() returns (Aut) {
    Aut aut = new Aut();
    return aut;
}

function deployCAutToken(address _owner, address _utilsRegistry) returns (CAut) {
    CAut cAut = new CAut(_owner, _utilsRegistry);
    return cAut;
}

function deployReputationMining(
    address _owner,
    address _aut,
    address _cAut,
    address _circular,
    address _peerValue,
    address _autId
) returns (ReputationMining) {
    ReputationMining reputationMiningImplementation = new ReputationMining();
    AutProxy reputationMiningProxy = new AutProxy(
        address(reputationMiningImplementation),
        _owner,
        abi.encodeWithSelector(ReputationMining.initialize.selector, _owner, _aut, _cAut, _circular, _peerValue, _autId)
    );
    return ReputationMining(address(reputationMiningProxy));
}

function deployDistributor(
    Aut _aut,
    address _sale,
    address _reputationMining,
    address _airdrop,
    address _founderInvestors,
    address _earlyContributors,
    address _listing,
    address _treasury,
    address _kolsAdvisors
) returns (Distributor) {
    Distributor distributor = new Distributor(
        _aut,
        _sale,
        _reputationMining,
        _airdrop,
        _founderInvestors,
        _earlyContributors,
        _listing,
        _treasury,
        _kolsAdvisors
    );
    return distributor;
}

function deployPeerValue(RandomNumberGenerator randomNumberGenerator) returns (PeerValue) {
    PeerValue peerValue = new PeerValue(randomNumberGenerator);
    return peerValue;
}

function deployPeerStaking(
    address _owner,
    address _autToken,
    address _cAutToken,
    address _circular,
    address _peerValue,
    address _reputationMining
) returns (PeerStaking) {
    PeerStaking peerStakingImplementation = new PeerStaking();
    AutProxy peerStakingProxy = new AutProxy(
        address(peerStakingImplementation),
        _owner,
        abi.encodeWithSelector(
            PeerStaking.initialize.selector,
            _owner,
            _autToken,
            _cAutToken,
            _circular,
            _peerValue,
            _reputationMining
        )
    );
    return PeerStaking(address(peerStakingProxy));
}
