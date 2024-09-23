// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "script/DeployAll.s.sol";
import {Hub} from "contracts/hub/Hub.sol";
import {
    console,
    StdAssertions,
    StdChains,
    StdCheats,
    stdError,
    StdInvariant,
    stdJson,
    stdMath,
    StdStorage,
    stdStorage,
    StdUtils,
    Vm,
    StdStyle,
    TestBase,
    Test
} from "forge-std/Test.sol";

abstract contract BaseTest is Test {
    AutID public autId;
    HubRegistry public hubRegistry;
    GlobalParameters public globalParameters;
    HubDomainsRegistry public hubDomainsRegistry;

    Hub public hub;

    RepFiRegistry public repFiRegistry;
    RepFi public repFi;
    PRepFi public pRepFi;
    TokenVesting public privateSale;
    TokenVesting public community;
    TokenVesting public investors;
    TokenVesting public team;
    ReputationMining public reputationMining;
    InitialDistribution public initialDistribution;
    RandomNumberGenerator public randomNumberGenerator;

    address public owner = address(this);
    address public alice = address(0x411Ce);
    address public bob = address(0xb0b);

    function setUp() public virtual {
        // setup and run deployment script
        DeployAll deploy = new DeployAll();
        deploy.setUp();
        deploy.setOwner(owner);
        deploy.run();
        vm.stopBroadcast();

        // set env
        autId = deploy.autId();
        hubRegistry = deploy.hubRegistry();
        globalParameters = deploy.globalParameters();
        hubDomainsRegistry = deploy.hubDomainsRegistry();

        _deployHub();

        repFiRegistry = deploy.repFiRegistry();

        repFi = deploy.repFi();
        pRepFi = deploy.pRepFi();

        privateSale = deploy.privateSale();
        community = deploy.community();
        investors = deploy.investors();
        team = deploy.team();

        randomNumberGenerator = deploy.randomNumberGenerator();
        reputationMining = deploy.reputationMining();
        initialDistribution = deploy.initialDistribution();

        // labeling
        vm.label(owner, "Owner");
        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(address(autId), "autId");
        vm.label(address(hubRegistry), "hubRegistry");
        vm.label(address(globalParameters), "globalParameters");
        vm.label(address(hubDomainsRegistry), "hubDomainsRegistry");
    }

    /// @dev deploy a basic hub
    function _deployHub() internal {
        uint256[] memory roles = new uint256[](3);
        roles[0] = 1;
        roles[1] = 2;
        roles[2] = 3;

        address hubAddress = hubRegistry.deployHub({roles: roles, market: 1, metadata: "Mock Metadata", commitment: 1});
        hub = Hub(hubAddress);
        vm.label(address(repFiRegistry), "repFiRegistry");
        vm.label(address(repFi), "repFi");
        vm.label(address(pRepFi), "pRepFi");
        vm.label(address(privateSale), "privateSale");
        vm.label(address(community), "community");
        vm.label(address(investors), "investors");
        vm.label(address(team), "team");
        vm.label(address(reputationMining), "reputationMining");
        vm.label(address(initialDistribution), "initialDistribution");
        vm.label(address(randomNumberGenerator), "peerValueContract");
    }
}
