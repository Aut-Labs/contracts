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

    UtilsRegistry public utilsRegistry;
    RepFi public repFi;
    PRepFi public pRepFi;
    address public sales;
    Investors public investors;
    Team public team;
    address public ecosystem;
    ReputationMining public reputationMining;
    Distributor public distributor;
    RandomNumberGenerator public randomNumberGenerator;
    PeerValue public peerValue;
    PeerStaking public peerStaking;

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

        utilsRegistry = deploy.utilsRegistry();

        repFi = deploy.repFi();
        pRepFi = deploy.pRepFi();

        sales = deploy.sales();
        investors = deploy.investors();
        team = deploy.team();
        ecosystem = deploy.ecosystem();

        randomNumberGenerator = deploy.randomNumberGenerator();
        reputationMining = deploy.reputationMining();
        distributor = deploy.distributor();
        peerValue = deploy.peerValue();
        peerStaking = deploy.peerStaking();

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
        vm.label(address(utilsRegistry), "utilsRegistry");
        vm.label(address(repFi), "repFi");
        vm.label(address(pRepFi), "pRepFi");
        vm.label(address(sales), "sales");
        vm.label(address(investors), "investors");
        vm.label(address(team), "team");
        vm.label(address(reputationMining), "reputationMining");
        vm.label(address(distributor), "distributor");
        vm.label(address(peerValue), "peerValueContract");
        vm.label(address(peerStaking), "peerStakingContract");
    }
}
