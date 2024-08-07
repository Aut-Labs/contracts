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
import {RepFiRegistry} from "../contracts/repfi/repFiRegistry/RepFiRegistry.sol";
import {RepFi} from "../contracts/repfi/token/REPFI.sol";
import {PRepFi} from "../contracts/repfi/token/pREPFI.sol";
import {TokenVesting} from "../contracts/repfi/vesting/TokenVesting.sol";
import {ReputationMining} from "../contracts/repfi/reputationMining/ReputationMining.sol";
import {InitialDistribution} from "../contracts/repfi/token/InitialDistribution.sol";

import "forge-std/Script.sol";

contract DeployAll is Script {
    address public owner;
    address public projectMultisig;
    uint256 public privateKey;
    bool public deploying;

    // state variables
    AutID public autId;
    PluginRegistry pluginRegistry;
    NovaRegistry public novaRegistry;
    GlobalParametersAlpha public globalParameters;
    HubDomainsRegistry public hubDomainsRegistry;
    BasicOnboarding public basicOnboarding;
    RepFiRegistry public repFiRegistry;
    RepFi public repFi;
    PRepFi public pRepFi;
    TokenVesting public privateSale;
    TokenVesting public community;
    TokenVesting public investors;
    TokenVesting public team;
    address public airdrop; // merkle
    address public partners; // multisig
    address public ecosystem; // multisig
    address public profitSharing;
    address public circular;
    ReputationMining public reputationMining;
    InitialDistribution public initialDistribution;

    struct TNamedAddress {
        address target;
        string name;
    }

    function setUpTest(address _owner) public {
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
        hubDomainsRegistry = deployHubDomainsRegistry();
        globalParameters = deployGlobalParameters(owner);
        novaRegistry = deployNovaRegistry({
            _trustedForwarder: trustedForwarder,
            _owner: owner,
            _autIdAddress: address(autId),
            _pluginRegistryAddress: address(pluginRegistry),
            _hubDomainsRegistryAddress: address(hubDomainsRegistry),
            _globalParametersAddress: address(globalParameters)
        });
        basicOnboarding = deployBasicOnboarding(owner);

        // set novaRegistry to autId (assumes msg.sender == owner [TODO: change this])
        // autId.setNovaRegistry(address(novaRegistry));

        // Create and set the allowlist
        Allowlist allowlist = new Allowlist();
        novaRegistry.setAllowlistAddress(address(allowlist));

        repFiRegistry = deployRepFiRegistry(owner);

        // deploy token contracts
        repFi = deployRepFiToken();
        pRepFi = deployPRepFiToken(address(owner), address(repFiRegistry));

        // deploy vesting contracts
        privateSale = deployTokenVesting(address(repFi), projectMultisig);
        community = deployTokenVesting(address(repFi), projectMultisig);
        investors = deployTokenVesting(address(repFi), projectMultisig);
        team = deployTokenVesting(address(repFi), projectMultisig);

        // deploy circular contract
        circular = makeAddr("circular"); // ToDo: update to Circular contract later

        // deploy profitSharing
        profitSharing = makeAddr("profitSharing"); // ToDo: update to ProfitSharing contract later

        airdrop = makeAddr("airdrop"); // ToDo: update to Airdrop contract later
        partners = makeAddr("partners"); // ToDo: update to partners multisig later
        ecosystem = makeAddr("ecosystem"); // ToDo: update to ecosystem multisig later

        // deploy reputationMining
        reputationMining = deployReputationMining(owner, address(repFi), address(pRepFi), address(circular));

        // deploy initialDistribution
        initialDistribution = deployInitialDistribution(
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

        // register repfi plugins, more to add later
        vm.startPrank(owner);
        // ToDo: give burner role to reputationmining in prepfi
        pRepFi.grantRole(pRepFi.BURNER_ROLE(), address(reputationMining));

        repFiRegistry.registerPlugin(address(address(this)), "DeployContract");
        repFiRegistry.registerPlugin(address(initialDistribution), "InitialDistribution");
        repFiRegistry.registerPlugin(address(reputationMining), "ReputationMining");
        vm.stopPrank();

        // send tokens to distribution contract
        repFi.transfer(address(initialDistribution), 100000000 ether); // 100 million repfi tokens

        // send pRepFi to reputationMining
        pRepFi.transfer(address(reputationMining), 36000000 ether);

        // transfer ownership to multisig for all contracts that have an owner

        // distribute tokens
        initialDistribution.distribute();

        // todo: convert to helper function
        if (deploying) {
            string memory filename = "deployments.txt";
            TNamedAddress[24] memory na;
            na[0] = TNamedAddress({name: "globalParametersProxy", target: address(globalParameters)});
            na[1] = TNamedAddress({name: "autIDProxy", target: address(autId)});
            na[2] = TNamedAddress({name: "novaRegistryProxy", target: address(novaRegistry)});
            na[3] = TNamedAddress({name: "pluginRegistryProxy", target: address(pluginRegistry)});
            na[4] = TNamedAddress({name: "allowlist", target: address(allowlist)});
            na[5] = TNamedAddress({name: "basicOnboarding", target: address(basicOnboarding)});
            na[9] = TNamedAddress({name: "hubDomainsRegistry", target: address(hubDomainsRegistry)});
            na[10] = TNamedAddress({name: "repFiRegistry", target: address(repFiRegistry)});
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
            na[23] = TNamedAddress({name: "initialDistribution", target: address(initialDistribution)});

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
    AutID autIdImplementation = new AutID(_trustedForwarder);
    AutProxy autIdProxy = new AutProxy(
        address(autIdImplementation),
        _owner,
        abi.encodeWithSelector(AutID.initialize.selector, msg.sender)
    );
    return AutID(address(autIdProxy));
}

function deployPluginRegistry(address _owner) returns (PluginRegistry) {
    PluginRegistry pluginRegistryImplementation = new PluginRegistry();
    AutProxy pluginRegistryProxy = new AutProxy(
        address(pluginRegistryImplementation),
        _owner,
        abi.encodeWithSelector(PluginRegistry.initialize.selector, _owner)
    );
    return PluginRegistry(address(pluginRegistryProxy));
}

function deployHubDomainsRegistry() returns (HubDomainsRegistry) {
    // address hubDomainsRegistry = address(new HubDomainsRegistry(novaImpl));
    HubDomainsRegistry hubDomainsRegistry = new HubDomainsRegistry(address(1)); // TODO
    return hubDomainsRegistry;
}

function deployGlobalParameters(address _owner) returns (GlobalParametersAlpha) {
    GlobalParametersAlpha globalParametersImplementation = new GlobalParametersAlpha();
    AutProxy globalParametersProxy = new AutProxy(address(globalParametersImplementation), _owner, "");
    return GlobalParametersAlpha(address(globalParametersProxy));
}

function deployNovaRegistry(
    address _trustedForwarder,
    address _owner,
    address _autIdAddress,
    address _pluginRegistryAddress,
    address _hubDomainsRegistryAddress,
    address _globalParametersAddress
) returns (NovaRegistry) {
    address novaImplementation = address(new Nova());
    address novaRegistryImplementation = address(new NovaRegistry(_trustedForwarder));
    AutProxy novaRegistryProxy = new AutProxy(
        novaRegistryImplementation,
        _owner,
        abi.encodeWithSelector(
            NovaRegistry.initialize.selector,
            _autIdAddress,
            novaImplementation,
            _pluginRegistryAddress,
            _hubDomainsRegistryAddress,
            _globalParametersAddress
        )
    );
    return NovaRegistry(address(novaRegistryProxy));
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

function deployRepFiRegistry(address _owner) returns (RepFiRegistry) {
    RepFiRegistry repFiRegistryImplementation = new RepFiRegistry();
    AutProxy repFiRegistryProxy = new AutProxy(
        address(repFiRegistryImplementation),
        _owner,
        abi.encodeWithSelector(RepFiRegistry.initialize.selector, _owner)
    );
    return RepFiRegistry(address(repFiRegistryProxy));
}

function deployRepFiToken() returns (RepFi) {
    RepFi repFi = new RepFi();
    return repFi;
}

function deployPRepFiToken(address _owner, address _repFiRegistry) returns (PRepFi) {
    PRepFi pRepFi = new PRepFi(_owner, _repFiRegistry);
    return pRepFi;
}

function deployTokenVesting(address _repFiToken, address _owner) returns (TokenVesting) {
    TokenVesting vesting = new TokenVesting(_repFiToken, _owner);

    // ToDo: set owner to multisig
    // vesting.transferOwnership(multisig);

    return vesting;
}

function deployReputationMining(
    address _owner,
    address _repFi,
    address _pRepFi,
    address _circular
) returns (ReputationMining) {
    ReputationMining reputationMiningImplementation = new ReputationMining();
    AutProxy reputationMiningProxy = new AutProxy(
        address(reputationMiningImplementation),
        _owner,
        abi.encodeWithSelector(ReputationMining.initialize.selector, _owner, _repFi, _pRepFi, _circular)
    );
    return ReputationMining(address(reputationMiningProxy));
}

function deployInitialDistribution(
    RepFi _repFi,
    TokenVesting _privateSale,
    TokenVesting _community,
    ReputationMining _reputationMining,
    address _airdrop,
    TokenVesting _investors,
    TokenVesting _team,
    address _partners,
    address _ecosystem
) returns (InitialDistribution) {
    InitialDistribution initialDistribution = new InitialDistribution(
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
    return initialDistribution;
}
