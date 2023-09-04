//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {DeploysInit} from "./DeploysInit.t.sol";

import {QuestOnboardingPlugin} from "../contracts/plugins/onboarding/QuestOnboardingPlugin.sol";
import {QuestPlugin} from "../contracts/plugins/quests/QuestPlugin.sol";

import {OffchainVerifiedTaskPlugin} from "../contracts/plugins/tasks/OffchainVerifiedTaskPlugin.sol";
import "forge-std/console.sol";
//// @notice Tests Basic Deployment attainable

contract TestQuestPlugin is DeploysInit {

    QuestOnboardingPlugin QOP;
    QuestPlugin QuestP;
    OffchainVerifiedTaskPlugin TaskPlugin;

    address offchainVerifier = address(256128256128000);
    uint256 taskPluginId;

    function setUp() public override {
        super.setUp();

        QOP = new QuestOnboardingPlugin(address(Nova));
        vm.label(address(QOP), "QuestOnboardingPlugin");

        QuestP = QuestPlugin(QOP.getQuestsPluginAddress());
        vm.label(address(QuestP), "QuestPlugin");

        TaskPlugin = new OffchainVerifiedTaskPlugin(address(Nova), offchainVerifier );
        vm.label(address(TaskPlugin), "TasksPlugin");

        uint256[] memory depmodrek;

        vm.prank(A0);
        uint256 pluginDefinitionID =
            IPR.addPluginDefinition(payable(A1), "owner can spoof metadata", 0, true, depmodrek);

        console.log("Created plugin definitinion ID --- :  ", pluginDefinitionID);
        vm.prank(A0);
        IPR.addPluginToDAO(address(TaskPlugin), pluginDefinitionID);

        taskPluginId = IPR.tokenIdFromAddress(address(TaskPlugin));
    }

    function testActivateQuest() public {
        vm.prank(A1);
        vm.expectRevert("Not an admin.");
        QOP.setActive(true);

        vm.startPrank(A0); //deployer is admin
        skip(100);

        vm.expectRevert("at least one quest needs to be defined");
        QOP.setActive(true);

        uint256 questID = QuestP.create(1, "uriCID", block.timestamp + 10, 1);
        assertTrue(questID != 0, "expected id");

        vm.expectRevert("at least one quest must have tasks");
        QOP.setActive(true);

        console.log(taskPluginId);
        QuestP.createTask(questID, taskPluginId, "taskUriMetadata");

        QOP.setActive(true); /////// sets active in

        QuestP.setQuestState(true, questID);
    }

    // let questOnboardingPlugin;
    // let questsPluginAddress, questsPlugin;
    // let deployer;
    // let addr1, addr2, addr3, addrs;
    // const url = "https://something";
    // let pluginTypeId;
    // let offchainVerifiedTaskPluginTypeId;
    // let autID;

    // describe("QuestOnboardingPlugin", (accounts) => {
    //   before(async function () {
    //     [admin, verifier, dao, addr1, addr2, addr3, ...addrs] =
    //       await ethers.getSigners();
    //     const ModuleRegistryFactory = await ethers.getContractFactory("ModuleRegistry");
    //     const moduleRegistry = await ModuleRegistryFactory.deploy();

    //     const PluginRegistryFactory = await ethers.getContractFactory(
    //       "PluginRegistry"
    //     );
    //     pluginRegistry = await PluginRegistryFactory.deploy(moduleRegistry.address);
    //     const AutID = await ethers.getContractFactory("AutID");

    //     autID = await upgrades.deployProxy(AutID, [admin.address], {
    //       from: admin,
    //     });
    //     await autID.deployed();

    //     const Nova = await ethers.getContractFactory("Nova");
    //     dao = await Nova.deploy(
    //       admin.address,
    //       autID.address,
    //       1,
    //       url,
    //       10,
    //       pluginRegistry.address
    //     );

    //     const questOnboardingDefinition = await (
    //       await pluginRegistry.addPluginDefinition(verifier.address, url, 0, true, [2])
    //     ).wait();
    //     pluginTypeId = questOnboardingDefinition.events[0].args.pluginTypeId.toString();

    //     const offchainVerifiedTaskDefinition = await (
    //       await pluginRegistry.addPluginDefinition(verifier.address, url, 0, true, [])
    //     ).wait();
    //     offchainVerifiedTaskPluginTypeId = offchainVerifiedTaskDefinition.events[0].args.pluginTypeId.toString();

    //     const OffchainVerifiedTaskPlugin = await ethers.getContractFactory(
    //       "OffchainVerifiedTaskPlugin"
    //     );
    //     offchainVerifiedTaskPlugin = await OffchainVerifiedTaskPlugin.deploy(
    //       dao.address,
    //       verifier.address
    //     );
    //     expect(offchainVerifiedTaskPlugin.address).not.null;

    //     let tx = await dao.connect(admin).activateModule(2);

    //     await expect(tx)
    //       .to.emit(dao, "ModuleActivated")
    //       .withArgs(2);

    //     tx = await pluginRegistry
    //       .connect(admin)
    //       .addPluginToDAO(offchainVerifiedTaskPlugin.address, offchainVerifiedTaskPluginTypeId);
    //     await expect(tx)
    //       .to.emit(pluginRegistry, "PluginAddedToDAO")
    //       .withArgs(1, offchainVerifiedTaskPluginTypeId, dao.address);

    //     const blockNumber = await ethers.provider.getBlockNumber();
    //     block = await ethers.provider.getBlock(blockNumber);

    //   });

    //   describe("Plugin Registration", async () => {
    //     it("Should deploy an QuestOnboardingPlugin", async () => {
    //       const QuestOnboardingPlugin = await ethers.getContractFactory(
    //         "QuestOnboardingPlugin"
    //       );
    //       questOnboardingPlugin = await QuestOnboardingPlugin.deploy(dao.address);

    //       expect(questOnboardingPlugin.address).not.null;

    //       questsPluginAddress = await questOnboardingPlugin.questsPlugin();

    //       expect(questsPluginAddress).not.null;
    //       const QuestPlugin = await ethers.getContractFactory("QuestPlugin");
    //       questsPlugin = QuestPlugin.attach(questsPluginAddress);
    //     });
    //     it("Should mint an NFT for it", async () => {
    //       const tx = await pluginRegistry
    //         .connect(admin)
    //         .addPluginToDAO(questOnboardingPlugin.address, pluginTypeId);
    //       await expect(tx)
    //         .to.emit(pluginRegistry, "PluginAddedToDAO")
    //         .withArgs(2, pluginTypeId, dao.address);
    //     });
    //   });

    //   describe("QuestOnboardingPlugin", async () => {
    //     it("Should revert onboard", async () => {
    //       const tx = questOnboardingPlugin.onboard(addr1.address, 0);
    //       await expect(tx).to.be.revertedWith("FunctionNotImplemented");
    //     });
    //     it("isOnboarded should return false if there are no quests", async () => {
    //       const isOnboarded = await questOnboardingPlugin.isOnboarded(
    //         addr1.address,
    //         0
    //       );
    //       expect(isOnboarded).to.be.false;
    //     });

    //     it("isOnboarded should return false not all quests are added", async () => {
    //       await questsPlugin.create(1, url, block.timestamp + 12, 1);

    //       const isOnboarded = await questOnboardingPlugin.isOnboarded(
    //         addr1.address,
    //         1
    //       );
    //       expect(isOnboarded).to.be.false;

    //     });

    //     it("should add all 3 quests", async () => {
    //       await questsPlugin.create(2, url, block.timestamp + 16, 1);
    //       await questsPlugin.create(3, url, block.timestamp + 16, 1);
    //     });

    //     it("should add task for the quests", async () => {
    //       tx = questsPlugin.createTask(1, 1, url);

    //       await expect(tx)
    //         .to.emit(offchainVerifiedTaskPlugin, "TaskCreated")
    //         .withArgs(1, url);

    //       tx = questsPlugin.createTask(2, 1, url);

    //       await expect(tx)
    //         .to.emit(offchainVerifiedTaskPlugin, "TaskCreated")
    //         .withArgs(2, url);
    //       tx = questsPlugin.createTask(3, 1, url);

    //       await expect(tx)
    //         .to.emit(offchainVerifiedTaskPlugin, "TaskCreated")
    //         .withArgs(3, url);

    //     });

    //     it("should activate onboarding", async () => {
    //       await questOnboardingPlugin.setActive(true);
    //       const isActive = await questOnboardingPlugin.isActive();
    //       expect(isActive).to.be.true;
    //     });

    //     it("should apply for a quest", async () => {
    //       const tx = questsPlugin.connect(addr2).applyForAQuest(1);

    //       await expect(tx)
    //         .to.emit(questsPlugin, "Applied")
    //         .withArgs(1, addr2.address);

    //       await questsPlugin.connect(addr1).applyForAQuest(1);

    //     });

    //     it("isOnboarded should return false if the quest is not active", async () => {
    //       const isOnboarded = await questOnboardingPlugin.isOnboarded(
    //         addr1.address,
    //         1
    //       );
    //       expect(isOnboarded).to.be.false;

    //     });
    //     function sleep(ms) {
    //       return new Promise(resolve => setTimeout(resolve, ms));
    //     }

    //     it("isOnboarded should return false if user hasn't applied for a quest", async () => {
    //       await sleep(1500);
    //       const task = await offchainVerifiedTaskPlugin.getById(1);
    //       expect(task["creator"]).to.eql(admin.address);
    //       tx = offchainVerifiedTaskPlugin
    //         .connect(verifier)
    //         .finalizeFor(1, addr3.address);

    //       await expect(tx)
    //         .to.emit(offchainVerifiedTaskPlugin, "TaskFinalized")
    //         .withArgs(1, addr3.address);

    //       const submissionStatus = await offchainVerifiedTaskPlugin.getStatusPerSubmitter(1, addr3.address);
    //       expect(submissionStatus.toString()).eq('3');

    //       const isOnboarded = await questOnboardingPlugin.isOnboarded(
    //         addr3.address,
    //         1
    //       );
    //       expect(isOnboarded).to.be.false;
    //     });

    //     it("isOnboarded should return true if onboarded for the correct role", async () => {

    //       const task = await offchainVerifiedTaskPlugin.getById(1);
    //       expect(task["creator"]).to.eql(admin.address);
    //       tx = offchainVerifiedTaskPlugin
    //         .connect(verifier)
    //         .finalizeFor(1, addr1.address);

    //       await expect(tx)
    //         .to.emit(offchainVerifiedTaskPlugin, "TaskFinalized")
    //         .withArgs(1, addr1.address);

    //       const submissionStatus = await offchainVerifiedTaskPlugin.getStatusPerSubmitter(1, addr1.address);
    //       expect(submissionStatus.toString()).eq('3');

    //       const isOnboarded = await questOnboardingPlugin.isOnboarded(
    //         addr1.address,
    //         1
    //       );
    //       expect(isOnboarded).to.be.true;
    //     });

    //     it("Should onboard another user", async () => {

    //       tx = offchainVerifiedTaskPlugin
    //         .connect(verifier)
    //         .finalizeFor(1, addr2.address);

    //       await expect(tx)
    //         .to.emit(offchainVerifiedTaskPlugin, "TaskFinalized")
    //         .withArgs(1, addr2.address);

    //       const submissionStatus = await offchainVerifiedTaskPlugin.getStatusPerSubmitter(1, addr2.address);
    //       expect(submissionStatus.toString()).eq('3');

    //       const isOnboarded = await questOnboardingPlugin.isOnboarded(
    //         addr2.address,
    //         1
    //       );
    //       expect(isOnboarded).to.be.true;
    //     });

    //   });
    // });
}
