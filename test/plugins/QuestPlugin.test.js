const { expect } = require("chai");
const { ethers } = require("hardhat");

let questPlugin;
let nova;
let pluginRegistry;
let moduleRegistry;
const url = "https://something";
let offchainVerifiedTaskPluginType;
let openTaskPlugin;
let questPluginType;
let autID;
let block;


describe("QuestPlugin", (accounts) => {
  before(async function () {
    [deployer, verifier, admin, addr1, addr2, addr3, ...addrs] =
      await ethers.getSigners();

    const ModuleRegistryFactory = await ethers.getContractFactory("ModuleRegistry");
    moduleRegistry = await ModuleRegistryFactory.deploy();

    const PluginRegistryFactory = await ethers.getContractFactory(
      "PluginRegistry"
    );
    pluginRegistry = await PluginRegistryFactory.deploy(moduleRegistry.address);
    const AutID = await ethers.getContractFactory("AutID");

    autID = await upgrades.deployProxy(AutID, [admin.address], {
      from: admin,
    });
    await autID.deployed();

    const Nova = await ethers.getContractFactory("Nova");
    nova = await Nova.deploy(
      admin.address,
      autID.address,
      1,
      url,
      10,
      pluginRegistry.address
    );
    const offchainTaskPluginDefinition = await (
      await pluginRegistry.addPluginDefinition(verifier.address, url, 0, true, [])
    ).wait();
    offchainVerifiedTaskPluginType =
    offchainTaskPluginDefinition.events[0].args.pluginTypeId.toString();

    const openTaskPluginDefinition = await (
      await pluginRegistry.addPluginDefinition(verifier.address, url, 0, true, [])
    ).wait();
    openTaskPluginType =
    openTaskPluginDefinition.events[0].args.pluginTypeId.toString();

    const questPluginDefinition = await (
      await pluginRegistry.addPluginDefinition(verifier.address, url, 0, true, [3])
    ).wait();
    questPluginType = questPluginDefinition.events[0].args.pluginTypeId.toString();

    const OffchainVerifiedTaskPlugin = await ethers.getContractFactory(
      "OffchainVerifiedTaskPlugin"
    );
    offchainVerifiedTaskPlugin = await OffchainVerifiedTaskPlugin.deploy(
      nova.address,
      verifier.address
    );

    const OpenTaskPlugin = await ethers.getContractFactory(
      "OpenTaskPlugin"
    );
    openTaskPlugin = await OpenTaskPlugin.deploy(
      nova.address,
      false
    );
    let tx = await nova
      .connect(admin)
      .activateModule(1);
    await expect(tx)
      .to.emit(nova, "ModuleActivated")
      .withArgs(1);
      
    tx = await nova
      .connect(admin)
      .activateModule(2);
    await expect(tx)
      .to.emit(nova, "ModuleActivated")
      .withArgs(2);
    // Add plugins to the DAO
     tx = await pluginRegistry
      .connect(admin)
      .addPluginToDAO(offchainVerifiedTaskPlugin.address, offchainVerifiedTaskPluginType);
    await expect(tx)
      .to.emit(pluginRegistry, "PluginAddedToDAO")
      .withArgs(1, offchainVerifiedTaskPluginType, nova.address);

    tx = await pluginRegistry
      .connect(admin)
      .addPluginToDAO(openTaskPlugin.address, openTaskPluginType);
    await expect(tx)
      .to.emit(pluginRegistry, "PluginAddedToDAO")
      .withArgs(2, openTaskPluginType, nova.address);

    const blockNumber = await ethers.provider.getBlockNumber();
    block = await ethers.provider.getBlock(blockNumber);

    tx = await openTaskPlugin.connect(admin).create(0, url, block.timestamp, block.timestamp + 1000);
    await expect(tx)
      .to.emit(openTaskPlugin, "TaskCreated")
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
      questPlugin = await QuestPlugin.deploy(nova.address);
      expect(questPlugin.address).not.null;
    });
    it("Should mint an NFT for it", async () => {
      const tx = await pluginRegistry
        .connect(admin)
        .addPluginToDAO(questPlugin.address, questPluginType);
      await expect(tx)
        .to.emit(pluginRegistry, "PluginAddedToDAO")
        .withArgs(3, questPluginType, nova.address);
    });
    it("Should create a quest", async () => {
      const tx = await questPlugin.connect(admin).create(1, url, block.timestamp + 20, 3);
      await expect(tx).to.emit(questPlugin, "QuestCreated").withArgs(1);
    });
    it("Should not create a quest if not an admin", async () => {
      const tx = questPlugin.create(1, url, block.timestamp, 3);
      await expect(tx).to.be.revertedWith("Not an admin.");
    });

    it("Should not create a task if not an admin", async () => {
      const tx = questPlugin.createTask(1, 1, url);
      await expect(tx).to.be.revertedWith("Not an admin.");
    });

    it("Should create a task", async () => {
      const tx = await questPlugin.connect(admin).createTask(1, offchainVerifiedTaskPluginType, url);
      await expect(tx).to.emit(questPlugin, "TasksAddedToQuest").withArgs(1, 3);

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
        { pluginId: offchainVerifiedTaskPluginType, taskId: 3 },
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


    // it("Should not complete if upper limit is reached", async () => {

    //   await expect(tx).to.be.revertedWith("invalid task");
    // });

  });
});
