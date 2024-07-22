// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "script/DeployAll.s.sol";
import { console2 as console, StdAssertions, StdChains, StdCheats, stdError, StdInvariant, stdJson, stdMath, StdStorage, stdStorage, StdUtils, Vm, StdStyle, TestBase, DSTest, Test } from "forge-std/Test.sol";

contract BaseTest is Test {
    AutID public autId;
    NovaRegistry public novaRegistry;
    GlobalParametersAlpha public globalParameters;
    HubDomainsRegistry public hubDomainsRegistry;
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
        novaRegistry = deploy.novaRegistry();
        globalParameters = deploy.globalParameters();
        hubDomainsRegistry = deploy.hubDomainsRegistry();
        basicOnboarding = deploy.basicOnboarding();

        // labeling
        vm.label(owner, "Owner");
        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(address(autId), "autId");
        vm.label(address(novaRegistry), "novaRegistry");
        vm.label(address(globalParameters), "globalParameters");
        vm.label(address(hubDomainsRegistry), "hubDomainsRegistry");
        vm.label(address(basicOnboarding), "basicOnboarding");
    }
}