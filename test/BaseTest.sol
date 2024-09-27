// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "script/DeployAll.s.sol";
import { Hub } from "contracts/hub/Hub.sol";
import { TaskRegistry, ITaskRegistry, Task } from "contracts/tasks/TaskRegistry.sol";
import { TaskFactory, ITaskFactory, Contribution } from "contracts/tasks/TaskFactory.sol";

import { console, StdAssertions, StdChains, StdCheats, stdError, StdInvariant, stdJson, stdMath, StdStorage, stdStorage, StdUtils, Vm, StdStyle, TestBase, Test } from "forge-std/Test.sol";

abstract contract BaseTest is Test {
    AutID public autId;
    HubRegistry public hubRegistry;
    TaskRegistry public taskRegistry;
    GlobalParameters public globalParameters;
    HubDomainsRegistry public hubDomainsRegistry;

    Hub public hub;
    TaskFactory public taskFactory;

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
        taskRegistry = deploy.taskRegistry();

        hub = _deployHub();
        taskFactory = TaskFactory(hub.taskFactory());

        _joinHub(alice, address(hub), "alice");

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
    function _deployHub() internal returns (Hub) {
        uint256[] memory roles = new uint256[](3);
        roles[0] = 1;
        roles[1] = 2;
        roles[2] = 3;

        address hubAddress = hubRegistry.deployHub({
            roles: roles,
            market: 1,
            metadata: "Mock Metadata",
            commitment: 1
        });
        return Hub(hubAddress);
    }

    function _joinHub(
        address who,
        address hubAddress,
        string memory username) internal {
        vm.prank(who);
        autId.createRecordAndJoinHub({
            role: 1,
            commitment: 1,
            hub: hubAddress,
            username: username,
            optionalURI: "https://facebook.com/someUser"
        });
    }

    function _createContribution(
        address who,
        address hubAddress,
        bytes32 taskId,
        uint256 role,
        uint32 startDate,
        uint32 endDate,
        uint32 points,
        uint128 quantity
    ) internal {
        vm.prank(who);
        Contribution memory contribution = Contribution({
            taskId: taskId,
            role: role,
            startDate: startDate,
            endDate: endDate,
            points: points,
            quantity: quantity,
            uri: ""
        });
        TaskFactory(Hub(hubAddress).taskFactory()).createContribution(contribution);

    }
}