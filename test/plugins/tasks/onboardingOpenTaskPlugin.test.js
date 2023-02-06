const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");

let onboardingOpenTaskPlugin;
let deployer;
let admin, submitter1, submitter2, addr1, addr2, addr3, addrs;
const url = "https://something";
let pluginTypeId;
let autID;
describe("OnboardingOpenTaskPlugin", (accounts) => {
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
    dao =  await AutDAO.deploy(
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
  });

  describe("Plugin Registration", async () => {
    it("Should deploy an OnboardingOpenTaskPlugin", async () => {
      const OnboardingOpenTaskPlugin = await ethers.getContractFactory(
        "OnboardingOpenTaskPlugin"
      );
      onboardingOpenTaskPlugin = await OnboardingOpenTaskPlugin.deploy(
        dao.address
      );

      expect(onboardingOpenTaskPlugin.address).not.null;
    });
    it("Should mint an NFT for it", async () => {
      const tx = await pluginRegistry
        .connect(admin)
        .addPluginToDAO(onboardingOpenTaskPlugin.address, pluginTypeId);
      await expect(tx)
        .to.emit(pluginRegistry, "PluginAddedToDAO")
        .withArgs(1, pluginTypeId, dao.address);
    });
  });

  describe("OnboardingOpenTaskPlugin", async () => {
    it("Should not create if signer is not an admin", async () => {
      const tx = onboardingOpenTaskPlugin.create(1, url);
      await expect(tx).to.be.revertedWith("Only admin.");
    });
    it("Should create a task", async () => {
      const tx = await onboardingOpenTaskPlugin.connect(admin).create(0, url);

      await expect(tx)
        .to.emit(onboardingOpenTaskPlugin, "TaskCreated")
        .withArgs(1, url);
      const task = await onboardingOpenTaskPlugin.getById("1");

      expect(task["metadata"]).to.eql(url);
      expect(task["creator"]).to.eql(admin.address);
      expect(task["taker"]).to.eql(ethers.constants.AddressZero);
      expect(task["role"].toString()).to.eql("0");
      expect(task["status"]).to.eql(0);
    });

    it("Should revert take", async () => {
      const tx = onboardingOpenTaskPlugin.take(1);
      await expect(tx).to.be.revertedWith("FunctionNotImplemented");
    });
    it("Should submit", async () => {
      const tx = onboardingOpenTaskPlugin.connect(submitter1).submit(1, url);
      await expect(tx)
        .to.emit(onboardingOpenTaskPlugin, "TaskSubmitted")
        .withArgs(1);
      const status = await onboardingOpenTaskPlugin.getStatusPerSubmitter(1, submitter1.address);
      expect(status).to.eql(2);
    });
    it("Should not submit same task twice", async () => {
      const tx = onboardingOpenTaskPlugin.connect(submitter1).submit(1, url);
      await expect(tx).to.be.revertedWith("FunctionInvalidAtThisStage");
    });
    it("Should revert finalize(uint256 taskId)", async () => {
      const tx = onboardingOpenTaskPlugin.finalize(1);
      await expect(tx).to.be.revertedWith("FunctionNotImplemented");
    });
    it("Should revert finalizeFor if signer not creator", async () => {
      const status = await onboardingOpenTaskPlugin.getStatusPerSubmitter(1, submitter1.address);
      const tx = onboardingOpenTaskPlugin.connect(submitter1).finalizeFor(1, submitter1.address);
      await expect(tx).to.be.revertedWith("Only creator.");
    });
    it("Should revert finalizeFor for an address that hasn't submitted", async () => {
      const tx = onboardingOpenTaskPlugin.connect(admin).finalizeFor(1, submitter2.address);
      await expect(tx).to.be.revertedWith("FunctionInvalidAtThisStage");
    });
    it("Should finalize", async () => {
      let status = await onboardingOpenTaskPlugin.getStatusPerSubmitter(
        1,
        submitter1.address
      );
      expect(status).to.eql(2);
      const tx = onboardingOpenTaskPlugin
        .connect(admin)
        .finalizeFor(1, submitter1.address);

      await expect(tx)
        .to.emit(onboardingOpenTaskPlugin, "TaskFinalized")
        .withArgs(1, submitter1.address);

      const interactions = await dao.getInteractionsPerUser(submitter1.address);
      expect(interactions.toString()).to.eql("1");

      status = await onboardingOpenTaskPlugin.getStatusPerSubmitter(
        1,
        submitter1.address
      );
      expect(status).to.eql(3);
    });

    it("Should return correctly hasCompletedTheTask", async () => {
      await expect(
        await onboardingOpenTaskPlugin.hasCompletedTheTask(submitter1.address, 1)
      ).to.be.true;
      await expect(
        await onboardingOpenTaskPlugin.hasCompletedTheTask(submitter2.address, 1)
      ).to.be.false;
      await expect(
        await onboardingOpenTaskPlugin.hasCompletedTheTask(submitter1.address, 2)
      ).to.be.false;
      await expect(
        await onboardingOpenTaskPlugin.hasCompletedTheTask(submitter2.address, 2)
      ).to.be.false;
    });
  });
});
