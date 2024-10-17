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

import {UtilsRegistry} from "../contracts/repfi/utilsRegistry/UtilsRegistry.sol";
import {RepFi} from "../contracts/repfi/token/REPFI.sol";
import {PRepFi} from "../contracts/repfi/token/pREPFI.sol";
import {PrivateSale} from "../contracts/repfi/vesting/PrivateSale.sol";
import {PublicSale} from "../contracts/repfi/vesting/PublicSale.sol";
import {Investors} from "../contracts/repfi/vesting/Investors.sol";
import {Team} from "../contracts/repfi/vesting/Team.sol";
import {Ecosystem} from "../contracts/repfi/vesting/Ecosystem.sol";
import {ReputationMining} from "../contracts/repfi/reputationMining/ReputationMining.sol";
import {Distributor} from "../contracts/repfi/token/Distributor.sol";
import {RandomNumberGenerator} from "../contracts/randomNumberGenerator/RandomNumberGenerator.sol";
import {PeerValue} from "../contracts/repfi/peerValue/PeerValue.sol";
import {PeerStaking} from "../contracts/repfi/peerStaking/PeerStaking.sol";

import "forge-std/Script.sol";

contract DeployAll is Script {
    address public owner;
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
    RepFi public repFi;
    PRepFi public pRepFi;
    PrivateSale public privateSale;
    PublicSale public community;
    Investors public investors;
    Team public team;
    address public airdrop; // merkle
    address public partners; // multisig
    Ecosystem public ecosystem;
    address public profitSharing;
    address public circular;
    ReputationMining public reputationMining;
    Distributor public distributor;
    RandomNumberGenerator public randomNumberGenerator;
    PeerValue public peerValue;
    PeerStaking public peerStaking;

    struct TNamedAddress {
        address target;
        string name;
    }

    function setOwner(address _owner) public {
        owner = _owner;
        projectMultisig = owner;
    }

    function setUp() public {
        if (block.chainid == 137) {
            owner = vm.envAddress("MAINNET_OWNER_ADDRESS");
            privateKey = vm.envUint("MAINNET_PRIVATE_KEY");
            projectMultisig = vm.envAddress("MAINNET_PROJECT_MULTISIG_ADDRESS");
        } else if (block.chainid == 80002) {
            owner = vm.envAddress("TESTNET_OWNER_ADDRESS");
            privateKey = vm.envUint("TESTNET_PRIVATE_KEY");
            projectMultisig = vm.envAddress("TESTNET_PROJECT_MULTISIG_ADDRESS");
        } else {
            // testing
            privateKey = 567890;
            owner = vm.addr(privateKey);
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
            _membershipImplementation: membershipImplementation,
            _participationImplementation: participationImplementation,
            _taskFactoryImplementation: taskFactoryImplementation,
            _taskManagerImplementation: taskManagerImplementation
        });

        // set hubRegistry to autId and transfer ownership
        autId.setHubRegistry(address(hubRegistry));
        autId.transferOwnership(owner);

        // init hubDomainsRegistry now that hubRegistry is deployed
        hubDomainsRegistry.initialize(address(hubRegistry));

        // Setup initial tasks
        Task[] memory tasks = new Task[](3);
        // open tasks
        tasks[0] = Task({uri: "ipfs://QmScDABgjA3MuiEDsLUDMpfe8cAKL1FgtSzLnGJVUF54Nx"});
        // quiz tasks
        tasks[1] = Task({uri: "ipfs://QmQZ2wXMsie8EGpbWk9GsRWQUj6JrJuBo7o3xCmnmZVWB7"});
        // join discord tasks
        tasks[2] = Task({uri: "ipfs://QmQnvc22SuY6x7qg1ujLFCg3E3QvrgfEEjam7rAbd69Rgu"});
        // polls
        // tasks[3] = Task({
        //     uri: "ipfs://QmQnvc22SuY6x7qg1ujLFCg3E3QvrgfEEjam7rAbd69Rgu"
        // });
        // // gathering tasks
        // tasks[4] = Task({
        //     uri: "ipfs://QmQnvc22SuY6x7qg1ujLFCg3E3QvrgfEEjam7rAbd69Rgu"
        // });
        taskRegistry.registerTasks(tasks);

        utilsRegistry = deployRepFiRegistry(owner);

        // deploy token contracts
        repFi = deployRepFiToken();
        pRepFi = deployPRepFiToken(address(owner), address(utilsRegistry));

        // deploy vesting contracts
        privateSale = deployPrivateSale(address(repFi), projectMultisig);
        community = deployPublicSale(address(repFi), projectMultisig);
        investors = deployInvestors(address(repFi), projectMultisig);
        team = deployTeam(address(repFi), projectMultisig);
        ecosystem = deployEcosystem(address(repFi), projectMultisig);

        // deploy circular contract
        circular = makeAddr("circular"); // ToDo: update to Circular contract later

        // deploy profitSharing
        profitSharing = makeAddr("profitSharing"); // ToDo: update to ProfitSharing contract later

        airdrop = makeAddr("airdrop"); // ToDo: update to Airdrop contract later
        partners = makeAddr("partners"); // ToDo: update to partners multisig later

        // ToDo: change this to the real contract when it's ready

        randomNumberGenerator = new RandomNumberGenerator();

        // deploy reputationMining
        reputationMining = deployReputationMining(
            owner,
            address(repFi),
            address(pRepFi),
            address(circular),
            address(randomNumberGenerator)
        );

        // deploy distributor
        distributor = deployInitialDistribution(
            repFi,
            privateSale,
            community,
            reputationMining,
            airdrop,
            investors,
            team,
            partners,
            ecosystem
        );

        // deploy PeerValue
        peerValue = deployPeerValue(randomNumberGenerator);

        // deploy PeerStaking
        peerStaking = deployPeerStaking(
            owner,
            address(repFi),
            address(pRepFi),
            address(circular),
            address(peerValue),
            address(reputationMining)
        );

        // register repfi plugins, more to add later

        vm.stopBroadcast();
        vm.startPrank(owner);
        // ToDo: give burner role to reputationmining in prepfi
        pRepFi.grantRole(pRepFi.BURNER_ROLE(), address(reputationMining));

        utilsRegistry.registerPlugin(address(address(this)), "DeployContract");
        // this is needed for tests because in BaseTest.sol the owner will be changed to the BaseTest contract
        utilsRegistry.registerPlugin(address(vm.addr(privateKey)), "owner");
        utilsRegistry.registerPlugin(address(distributor), "Distributor");
        utilsRegistry.registerPlugin(address(reputationMining), "ReputationMining");
        utilsRegistry.registerPlugin(address(peerValue), "PeerValue");
        utilsRegistry.registerPlugin(address(peerStaking), "PeerStaking");

        vm.stopPrank();

        vm.startBroadcast(privateKey);

        // send tokens to distribution contract
        repFi.transfer(address(distributor), 100000000 ether); // 100 million repfi tokens

        // send pRepFi to reputationMining
        pRepFi.transfer(address(reputationMining), 36000000 ether);

        // transfer ownership to multisig for all contracts that have an owner

        // distribute tokens
        distributor.distribute();

        // todo: convert to helper function
        if (deploying) {
            string memory filename = "deployments.txt";
            TNamedAddress[24] memory na;
            na[0] = TNamedAddress({name: "globalParametersProxy", target: address(globalParameters)});
            na[1] = TNamedAddress({name: "autIDProxy", target: address(autId)});
            na[2] = TNamedAddress({name: "hubRegistryProxy", target: address(hubRegistry)});
            na[3] = TNamedAddress({name: "hubDomainsRegistry", target: address(hubDomainsRegistry)});
            na[4] = TNamedAddress({name: "taskRegistry", target: address(taskRegistry)});
            na[10] = TNamedAddress({name: "utilsRegistry", target: address(utilsRegistry)});
            na[11] = TNamedAddress({name: "repFi", target: address(repFi)});
            na[12] = TNamedAddress({name: "pRepFi", target: address(pRepFi)});
            na[13] = TNamedAddress({name: "privateSale", target: address(privateSale)});
            na[14] = TNamedAddress({name: "community", target: address(community)});
            na[15] = TNamedAddress({name: "investors", target: address(investors)});
            na[16] = TNamedAddress({name: "team", target: address(team)});
            na[17] = TNamedAddress({name: "airdrop", target: address(airdrop)});
            na[18] = TNamedAddress({name: "partners", target: address(partners)});
            na[19] = TNamedAddress({name: "ecosystem", target: address(ecosystem)});
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
                _membershipImplementation,
                _participationImplementation,
                _taskFactoryImplementation,
                _taskManagerImplementation
            )
        )
    );
    return HubRegistry(address(hubRegistryProxy));
}

function deployRepFiRegistry(address _owner) returns (UtilsRegistry) {
    UtilsRegistry repFiRegistryImplementation = new UtilsRegistry();
    AutProxy repFiRegistryProxy = new AutProxy(
        address(repFiRegistryImplementation),
        _owner,
        abi.encodeWithSelector(UtilsRegistry.initialize.selector, _owner)
    );
    return UtilsRegistry(address(repFiRegistryProxy));
}

function deployRepFiToken() returns (RepFi) {
    RepFi repFi = new RepFi();
    return repFi;
}

function deployPRepFiToken(address _owner, address _repFiRegistry) returns (PRepFi) {
    PRepFi pRepFi = new PRepFi(_owner, _repFiRegistry);
    return pRepFi;
}

function deployPrivateSale(address _repFiToken, address _owner) returns (PrivateSale) {
    PrivateSale vesting = new PrivateSale(_repFiToken, _owner);
    return vesting;
}

function deployPublicSale(address _repFiToken, address _owner) returns (PublicSale) {
    PublicSale vesting = new PublicSale(_repFiToken, _owner);
    return vesting;
}

function deployInvestors(address _repFiToken, address _owner) returns (Investors) {
    Investors vesting = new Investors(_repFiToken, _owner);
    return vesting;
}

function deployTeam(address _repFiToken, address _owner) returns (Team) {
    Team vesting = new Team(_repFiToken, _owner);
    return vesting;
}

function deployEcosystem(address _repFiToken, address _owner) returns (Ecosystem) {
    Ecosystem vesting = new Ecosystem(_repFiToken, _owner);
    return vesting;
}

function deployReputationMining(
    address _owner,
    address _repFi,
    address _pRepFi,
    address _circular,
    address _randomNumberGenerator
) returns (ReputationMining) {
    ReputationMining reputationMiningImplementation = new ReputationMining();
    AutProxy reputationMiningProxy = new AutProxy(
        address(reputationMiningImplementation),
        _owner,
        abi.encodeWithSelector(
            ReputationMining.initialize.selector,
            _owner,
            _repFi,
            _pRepFi,
            _circular,
            _randomNumberGenerator
        )
    );
    return ReputationMining(address(reputationMiningProxy));
}

function deployInitialDistribution(
    RepFi _repFi,
    PrivateSale _privateSale,
    PublicSale _community,
    ReputationMining _reputationMining,
    address _airdrop,
    Investors _investors,
    Team _team,
    address _partners,
    Ecosystem _ecosystem
) returns (Distributor) {
    Distributor distributor = new Distributor(
        _repFi,
        _privateSale,
        _community,
        _reputationMining,
        _airdrop,
        _investors,
        _team,
        _partners,
        _ecosystem
    );
    return distributor;
}

function deployPeerValue(RandomNumberGenerator randomNumberGenerator) returns (PeerValue) {
    PeerValue peerValue = new PeerValue(randomNumberGenerator);
    return peerValue;
}

function deployPeerStaking(
    address _owner,
    address _repFiToken,
    address _pRepFiToken,
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
            _repFiToken,
            _pRepFiToken,
            _circular,
            _peerValue,
            _reputationMining
        )
    );
    return PeerStaking(address(peerStakingProxy));
}
