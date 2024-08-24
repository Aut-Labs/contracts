// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "script/DeployAll.s.sol";
import { console, StdAssertions, StdChains, StdCheats, stdError, StdInvariant, stdJson, stdMath, StdStorage, stdStorage, StdUtils, Vm, StdStyle, TestBase, Test } from "forge-std/Test.sol";

abstract contract BaseTest is Test {
    AutID public autId;
    HubRegistry public hubRegistry;
    GlobalParameters public globalParameters;
    HubDomainsRegistry public hubDomainsRegistry;
    InteractionRegistry public interactionRegistry;
    BasicOnboarding public basicOnboarding;

    address public owner = address(this);
    address public alice = address(0x411Ce);
    address public bob = address(0xb0b);

    function setUp() public virtual {
        // setup and run deployment script
        DeployAll deploy = new DeployAll();
        deploy.setUpTest(owner);
        deploy.run();

        // set env
        autId = deploy.autId();
        hubRegistry = deploy.hubRegistry();
        globalParameters = deploy.globalParameters();
        hubDomainsRegistry = deploy.hubDomainsRegistry();
        interactionRegistry = deploy.interactionRegistry();
        basicOnboarding = deploy.basicOnboarding();

        // labeling
        vm.label(owner, "Owner");
        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(address(autId), "autId");
        vm.label(address(hubRegistry), "hubRegistry");
        vm.label(address(globalParameters), "globalParameters");
        vm.label(address(hubDomainsRegistry), "hubDomainsRegistry");
        vm.label(address(basicOnboarding), "basicOnboarding");
    }
}