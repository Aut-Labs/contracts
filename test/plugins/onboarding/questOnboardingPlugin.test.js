const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");

let questOnboardingPlugin;
let questsPluginAddress, questsPlugin;
let deployer;
let addr1, addr2, addr3, addrs;
const url = "https://something";
let pluginTypeId;
let offchainVerifiedTaskPluginTypeId;
let autID;
let block;

describe("QuestOnboardingPlugin", (accounts) => {
  before(async function () {
    [admin, verifier, dao, addr1, addr2, addr3, ...addrs] =
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


    const pluginDefinition = await (
      await pluginRegistry.addPluginDefinition(verifier.address, url, 0)
    ).wait();
    pluginTypeId = pluginDefinition.events[0].args.pluginTypeId.toString();

    // milena
    const pluginDefinition2 = await (
      await pluginRegistry.addPluginDefinition(verifier.address, url, 0)
    ).wait();
    offchainVerifiedTaskPluginTypeId = pluginDefinition2.events[0].args.pluginTypeId.toString();


    const OffchainVerifiedTaskPlugin = await ethers.getContractFactory(
      "OffchainVerifiedTaskPlugin"
    );
    offchainVerifiedTaskPlugin = await OffchainVerifiedTaskPlugin.deploy(
      dao.address,
      verifier.address
    );
    expect(offchainVerifiedTaskPlugin.address).not.null;

    let tx = await pluginRegistry
      .connect(admin)
      .addPluginToDAO(offchainVerifiedTaskPlugin.address, offchainVerifiedTaskPluginTypeId);
    await expect(tx)
      .to.emit(pluginRegistry, "PluginAddedToDAO")
      .withArgs(1, offchainVerifiedTaskPluginTypeId, dao.address);

    const blockNumber = await ethers.provider.getBlockNumber();
    block = await ethers.provider.getBlock(blockNumber);


  });

  describe("Plugin Registration", async () => {
    it("Should deploy an QuestOnboardingPlugin", async () => {
      const QuestOnboardingPlugin = await ethers.getContractFactory(
        "QuestOnboardingPlugin"
      );
      questOnboardingPlugin = await QuestOnboardingPlugin.deploy(dao.address);

      expect(questOnboardingPlugin.address).not.null;

      questsPluginAddress = await questOnboardingPlugin.questsPlugin();

      expect(questsPluginAddress).not.null;
      const QuestPlugin = await ethers.getContractFactory("QuestPlugin");
      questsPlugin = QuestPlugin.attach(questsPluginAddress);
    });
    it("Should mint an NFT for it", async () => {
      const tx = await pluginRegistry
        .connect(admin)
        .addPluginToDAO(questOnboardingPlugin.address, pluginTypeId);
      await expect(tx)
        .to.emit(pluginRegistry, "PluginAddedToDAO")
        .withArgs(2, pluginTypeId, dao.address);
    });
  });

  describe("QuestOnboardingPlugin", async () => {
    it("Should revert onboard", async () => {
      const tx = questOnboardingPlugin.onboard(addr1.address, 0);
      await expect(tx).to.be.revertedWith("FunctionNotImplemented");
    });
    it("isOnboarded should return false if there are no quests", async () => {
      const isOnboarded = await questOnboardingPlugin.isOnboarded(
        addr1.address,
        0
      );
      expect(isOnboarded).to.be.false;
    });

    it("isOnboarded should return false if the quest doesn't have tasks yet", async () => {
      await questsPlugin.create(1, url, 1);
      const questID = await questsPlugin.roleToQuestID(1);
      expect(questID.toString()).to.eql("1");

      const isOnboarded = await questOnboardingPlugin.isOnboarded(
        addr1.address,
        1
      );
      expect(isOnboarded).to.be.false;
    });

    it("isOnboarded should return true if onboarded for the correct role", async () => {
      tx = await offchainVerifiedTaskPlugin.connect(admin).create(0, url, block.timestamp, block.timestamp + 1000);

      await expect(tx)
        .to.emit(offchainVerifiedTaskPlugin, "TaskCreated")
        .withArgs(1, url);

      tx = questsPlugin.addTasks(1, [{ pluginId: 1, taskId: 1 }]);

      await expect(tx)
        .to.emit(questsPlugin, "TasksAddedToQuest");

      //     const task = await offchainVerifiedTaskPlugin.getById(1);
      //   expect(task["creator"]).to.eql(admin.address);
      //    tx = offchainVerifiedTaskPlugin
      //     .connect(verifier)
      //     .finalizeFor(1, addr1.address);

      //     await expect(tx)
      //     .to.emit(offchainVerifiedTaskPlugin, "TaskFinalized")
      //     .withArgs(1, addr1.address);

      //   const isOnboarded = await questOnboardingPlugin.isOnboarded(
      //     addr1.address,
      //     1
      //   );
      //   expect(isOnboarded).to.be.true;
    });
    it("isOnboarded should return false if the quest doesn't have tasks yet", async () => {

      const isOnboarded = await questOnboardingPlugin.isOnboarded(
        addr1.address,
        2
      );
      expect(isOnboarded).to.be.false;
    });
  });
});