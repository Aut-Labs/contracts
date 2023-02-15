const { expect } = require("chai");
const { ethers } = require("hardhat");

let questPlugin;
let dao;
let pluginRegistry;
const url = "https://something";
let offchainVerifiedTaskPluginType;
let onboardingOpenTaskPluginType;
let questPluginType;
let autID;
let block;

describe("QuestPlugin", (accounts) => {
  before(async function () {
    [deployer, verifier, admin, addr1, addr2, addr3, ...addrs] =
      await ethers.getSigners();
    const PluginRegistryFactory = await ethers.getContractFactory(
      "PluginRegistry"
    );
    pluginRegistry = await PluginRegistryFactory.deploy();
    const AutID = await ethers.getContractFactory("AutID");

    autID = await upgrades.deployProxy(AutID, [admin.address], {
      from: admin,
    });
    await autID.deployed();

    const AutDAO = await ethers.getContractFactory("AutDAO");
    dao = await AutDAO.deploy(
      admin.address,
      autID.address,
      1,
      url,
      10,
      pluginRegistry.address
    );
    const pluginDefinition1 = await (
      await pluginRegistry.addPluginDefinition(verifier.address, url, 0)
    ).wait();
    offchainVerifiedTaskPluginType =
      pluginDefinition1.events[0].args.pluginTypeId.toString();

    const pluginDefinition2 = await (
      await pluginRegistry.addPluginDefinition(verifier.address, url, 0)
    ).wait();
    onboardingOpenTaskPluginType =
      pluginDefinition2.events[0].args.pluginTypeId.toString();

    const pluginDefinition3 = await (
      await pluginRegistry.addPluginDefinition(verifier.address, url, 0)
    ).wait();
    questPluginType = pluginDefinition3.events[0].args.pluginTypeId.toString();

    const OffchainVerifiedTaskPlugin = await ethers.getContractFactory(
      "OnboardingQuestOffchainVerifiedTaskPlugin"
    );
    offchainVerifiedTaskPlugin = await OffchainVerifiedTaskPlugin.deploy(
      dao.address,
      verifier.address,
      ethers.constants.AddressZero

    );

    const OnboardingOpenTaskPlugin = await ethers.getContractFactory(
      "OnboardingQuestOpenTaskPlugin"
    );
    onboardingOpenTaskPlugin = await OnboardingOpenTaskPlugin.deploy(
      dao.address,
      ethers.constants.AddressZero
    );

    // Add plugins to the DAO
    let tx = await pluginRegistry
      .connect(admin)
      .addPluginToDAO(offchainVerifiedTaskPlugin.address, offchainVerifiedTaskPluginType);
    await expect(tx)
      .to.emit(pluginRegistry, "PluginAddedToDAO")
      .withArgs(1, offchainVerifiedTaskPluginType, dao.address);

    tx = await pluginRegistry
      .connect(admin)
      .addPluginToDAO(onboardingOpenTaskPlugin.address, onboardingOpenTaskPluginType);
    await expect(tx)
      .to.emit(pluginRegistry, "PluginAddedToDAO")
      .withArgs(2, onboardingOpenTaskPluginType, dao.address);

      const blockNumber = await ethers.provider.getBlockNumber();
      block = await ethers.provider.getBlock(blockNumber);
  

    tx = await onboardingOpenTaskPlugin.connect(admin).create(0, url, block.timestamp, block.timestamp + 1000);
    await expect(tx)
      .to.emit(onboardingOpenTaskPlugin, "TaskCreated")
      .withArgs(1, url);
    tx = await offchainVerifiedTaskPlugin.connect(admin).create(0, url, block.timestamp, block.timestamp + 1000);
    await expect(tx)
      .to.emit(offchainVerifiedTaskPlugin, "TaskCreated")
      .withArgs(1, url);
    tx = await offchainVerifiedTaskPlugin.connect(admin).create(0, url, block.timestamp, block.timestamp + 1000);
    await expect(tx)
      .to.emit(offchainVerifiedTaskPlugin, "TaskCreated")
      .withArgs(2, url);
  });

  describe("Quests Plugin", async () => {
    it("Should deploy a QuestPlugin", async () => {
      const QuestPlugin = await ethers.getContractFactory("QuestPlugin");
      questPlugin = await QuestPlugin.deploy(dao.address);
      expect(questPlugin.address).not.null;

      await offchainVerifiedTaskPlugin.connect(admin).setQuestsAddress(questPlugin.address);
      await onboardingOpenTaskPlugin.connect(admin).setQuestsAddress(questPlugin.address);
    });
    it("Should mint an NFT for it", async () => {
      const tx = await pluginRegistry
        .connect(admin)
        .addPluginToDAO(questPlugin.address, questPluginType);
      await expect(tx)
        .to.emit(pluginRegistry, "PluginAddedToDAO")
        .withArgs(3, questPluginType, dao.address);
    });
    it("Should create a quest", async () => {
      const tx = await questPlugin.connect(admin).create(1, url, 3, 100);
      await expect(tx).to.emit(questPlugin, "QuestCreated").withArgs(1);
    });
    it("Should not create a quest if not an admin", async () => {
      const tx = questPlugin.create(1, url, 3, 100);
      await expect(tx).to.be.revertedWith("Not an admin.");
    });


    it("Should not create a task if not an admin", async () => {
      const tx = questPlugin.createTask(1, 1, url);
      await expect(tx).to.be.revertedWith("Not an admin.");
    });

    it("Should create a task", async () => {
      const tx = await questPlugin.connect(admin).createTask(1, offchainVerifiedTaskPluginType, url);
      await expect(tx).to.emit(questPlugin, "TasksAddedToQuest").withArgs(1, 6);

      const quest = await questPlugin.getById(1);
      expect(quest.tasksCount.toString()).eql("1");
    });

    it("Should not remove a task to a quest if not an admin", async () => {
      const tx = questPlugin.removeTasks(1, [{ pluginId: 9, taskId: 1 }]);
      await expect(tx).to.be.revertedWith("Not an admin.");
    });
    it("Should not remove a task if not added", async () => {
      const tx = questPlugin.connect(admin).removeTasks(1, [
        { pluginId: offchainVerifiedTaskPluginType, taskId: 1 },
      ]);
      await expect(tx).to.be.revertedWith("invalid task");

    });

    it("Should remove a task", async () => {
      const tx = await questPlugin.connect(admin).removeTasks(1, [
        { pluginId: offchainVerifiedTaskPluginType, taskId: 6 },
      ]);

      await expect(tx).to.emit(questPlugin, "TasksRemovedFromQuest");

      const quest = await questPlugin.getById(1);
      expect(quest.tasksCount.toString()).eql("0");
    });
    it("Should not remove a task if it's not present", async () => {
      const tx = questPlugin.connect(admin).removeTasks(1, [
        { pluginId: offchainVerifiedTaskPluginType, taskId: 1 },
      ]);

      await expect(tx).to.be.revertedWith("invalid task");
    });
    
  });
});
