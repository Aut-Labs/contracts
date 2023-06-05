const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");

let openTaskPlugin;
let deployer;
let admin, submitter1, submitter2, addr1, addr2, addr3, addrs;
const url = "https://something";
let pluginTypeId;
let autID;
let block;


describe("OpenTaskPlugin", (accounts) => {
  before(async function () {
    [
      admin,
      verifier,
      dao,
      admin,
      submitter1,
      submitter2,
      addr1,
      addr2,
      addr3,
      ...addrs
    ] = await ethers.getSigners();

    const ModuleRegistryFactory = await ethers.getContractFactory("ModuleRegistry");
    const moduleRegistry = await ModuleRegistryFactory.deploy();

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
    dao = await Nova.deploy(
      admin.address,
      autID.address,
      1,
      url,
      10,
      pluginRegistry.address
    );

    const pluginDefinition = await (
      await pluginRegistry.addPluginDefinition(verifier.address, url, 0, true, [])
    ).wait();
    pluginTypeId = pluginDefinition.events[0].args.pluginTypeId.toString();

    const blockNumber = await ethers.provider.getBlockNumber();
    block = await ethers.provider.getBlock(blockNumber);

  });

  describe("Plugin Registration", async () => {
    it("Should deploy an OnboardingQuestOpenTaskPlugin", async () => {
      const OpenTaskPlugin = await ethers.getContractFactory(
        "OpenTaskPlugin"
      );
      openTaskPlugin = await OpenTaskPlugin.deploy(
        dao.address,
        false
      );

      expect(openTaskPlugin.address).not.null;
    });
    it("Should mint an NFT for it", async () => {
      const tx = await pluginRegistry
        .connect(admin)
        .addPluginToDAO(openTaskPlugin.address, pluginTypeId);
      await expect(tx)
        .to.emit(pluginRegistry, "PluginAddedToDAO")
        .withArgs(1, pluginTypeId, dao.address);
    });
  });

  describe("OnboardingOpenTaskPlugin", async () => {
    it("Should not create if signer is not an admin", async () => {
      const tx = openTaskPlugin.create(1, url, block.timestamp, block.timestamp + 1000);
      await expect(tx).to.be.revertedWith("Only admin.");
    });
    it("Should not create a task if wront dates", async () => {
      const tx = openTaskPlugin.connect(admin).create(1, url, block.timestamp, block.timestamp - 1000);
      await expect(tx).to.be.revertedWith("Invalid endDate");
    });
    it("Should create a task", async () => {
      const tx = await openTaskPlugin.connect(admin).create(0, url, block.timestamp, block.timestamp + 1000);

      await expect(tx)
        .to.emit(openTaskPlugin, "TaskCreated")
        .withArgs(1, url);
      const task = await openTaskPlugin.getById("1");

      expect(task["metadata"]).to.eql(url);
      expect(task["creator"]).to.eql(admin.address);
      expect(task["role"].toString()).to.eql("0");
    });

    it("Should revert take", async () => {
      const tx = openTaskPlugin.take(1);
      await expect(tx).to.be.revertedWith("FunctionNotImplemented");
    });
    it("Should submit", async () => {
      const tx = openTaskPlugin.connect(submitter1).submit(1, url);
      await expect(tx)
        .to.emit(openTaskPlugin, "TaskSubmitted")
        .withArgs(1, 1);
      const status = await openTaskPlugin.getStatusPerSubmitter(1, submitter1.address);
      expect(status).to.eql(2);
    });
    it("Should return correct submissions", async () => {
      const status = await openTaskPlugin.getStatusPerSubmitter(1, submitter1.address);
      const subIds = await openTaskPlugin.getSubmissionIdsPerTask(1);
      const subId = await openTaskPlugin.getSubmissionIdPerTaskAndUser(1, submitter1.address);
      const submission = await openTaskPlugin.submissions(1);
      expect(status).to.eql(2);
      expect(subIds[0].toString()).to.eql("1");
      expect(subIds.length).to.eql(1);
      expect(subId.toString()).to.eql("1");
      expect(submission["submitter"]).to.eql(submitter1.address);
      expect(submission["submissionMetadata"]).to.eql(url);
      expect(submission["completionTime"].toString()).to.eql("0");
      expect(submission["status"].toString()).to.eql("2");
    });
    it("Should not submit same task twice", async () => {
      const tx = openTaskPlugin.connect(submitter1).submit(1, url);
      await expect(tx).to.be.revertedWith("FunctionInvalidAtThisStage");
    });
    it("Should revert finalize(uint256 taskId)", async () => {
      const tx = openTaskPlugin.finalize(1);
      await expect(tx).to.be.revertedWith("FunctionNotImplemented");
    });
    it("Should revert finalizeFor if signer not creator", async () => {
      const tx = openTaskPlugin.connect(submitter1).finalizeFor(1, submitter1.address);
      await expect(tx).to.be.revertedWith("Only creator.");
    });
    it("Should revert finalizeFor for an address that hasn't submitted", async () => {
      const tx = openTaskPlugin.connect(admin).finalizeFor(1, submitter2.address);
      await expect(tx).to.be.revertedWith("FunctionInvalidAtThisStage");
    });
    it("Should finalize", async () => {
      let status = await openTaskPlugin.getStatusPerSubmitter(
        1,
        submitter1.address
      );
      expect(status).to.eql(2);
      const tx = openTaskPlugin
        .connect(admin)
        .finalizeFor(1, submitter1.address);

      await expect(tx)
        .to.emit(openTaskPlugin, "TaskFinalized")
        .withArgs(1, submitter1.address);

      const interactions = await dao.getInteractionsPerUser(submitter1.address);
      expect(interactions.toString()).to.eql("1");

      status = await openTaskPlugin.getStatusPerSubmitter(
        1,
        submitter1.address
      );

      expect(status).to.eql(3);

      const submission = await openTaskPlugin.submissions(1);
      expect(submission["submitter"]).to.eql(submitter1.address);
      expect(submission["submissionMetadata"]).to.eql(url);
      expect(+submission["completionTime"].toString()).to.gt(100000);
      expect(submission["status"].toString()).to.eql("3");

    });

    it("Should return correctly hasCompletedTheTask", async () => {
      await expect(
        await openTaskPlugin.hasCompletedTheTask(submitter1.address, 1)
      ).to.be.true;
      await expect(
        await openTaskPlugin.hasCompletedTheTask(submitter2.address, 1)
      ).to.be.false;
      await expect(
        await openTaskPlugin.hasCompletedTheTask(submitter1.address, 2)
      ).to.be.false;
      await expect(
        await openTaskPlugin.hasCompletedTheTask(submitter2.address, 2)
      ).to.be.false;
    });
  });
});
