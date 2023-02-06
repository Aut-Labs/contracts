const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");

let offchainVerifiedTaskPlugin;
let deployer;
let addr1, addr2, addr3, addrs;
const url = "https://something";
let pluginTypeId;
let autID;

describe("OffchainVerifiedTaskPlugin", (accounts) => {
  before(async function () {
    [admin, verifier, dao, addr2, addr3, ...addrs] =
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
    it("Should deploy an OffchainVerifiedTaskPlugin", async () => {
      const OffchainVerifiedTaskPlugin = await ethers.getContractFactory(
        "OffchainVerifiedTaskPlugin"
      );
      offchainVerifiedTaskPlugin = await OffchainVerifiedTaskPlugin.deploy(
        dao.address,
        verifier.address
      );

      expect(offchainVerifiedTaskPlugin.address).not.null;
    });
    it("Should mint an NFT for it", async () => {
      const tx = await pluginRegistry
        .connect(admin)
        .addPluginToDAO(offchainVerifiedTaskPlugin.address, pluginTypeId);
      await expect(tx)
        .to.emit(pluginRegistry, "PluginAddedToDAO")
        .withArgs(1, pluginTypeId, dao.address);
    });
  });

  describe("OffchainVerifiedTaskPlugin", async () => {
    it("Should not create if signer is not an admin", async () => {
      const tx = offchainVerifiedTaskPlugin.connect(addr2).create(1, url);
      await expect(tx).to.be.revertedWith("Only admin.");
    });
    it("Should create a task", async () => {
      const tx = await offchainVerifiedTaskPlugin.connect(admin).create(0, url);

      await expect(tx)
        .to.emit(offchainVerifiedTaskPlugin, "TaskCreated")
        .withArgs(1, url);
      const task = await offchainVerifiedTaskPlugin.getById(1);

      expect(task["metadata"]).to.eql(url);
      expect(task["creator"]).to.eql(admin.address);
      expect(task["taker"]).to.eql(ethers.constants.AddressZero);
      expect(task["role"].toString()).to.eql("0");
      expect(task["status"]).to.eql(0);
    });

    it("Should revert take", async () => {
      const tx = offchainVerifiedTaskPlugin.take(1);
      await expect(tx).to.be.revertedWith("FunctionNotImplemented");
    });
    it("Should revert submit", async () => {
      const tx = offchainVerifiedTaskPlugin.submit(1, url);
      await expect(tx).to.be.revertedWith("FunctionNotImplemented");
    });
    it("Should revert finalize(uint256 taskId)", async () => {
      const tx = offchainVerifiedTaskPlugin.finalize(1);
      await expect(tx).to.be.revertedWith("FunctionNotImplemented");
    });
    it("Should revert finalizeFor if signer not offchain verifier", async () => {
      const tx = offchainVerifiedTaskPlugin.finalizeFor(1, addr2.address);
      await expect(tx).to.be.revertedWith("Only offchain verifier.");
    });
    it("Should finalize", async () => {
      let status = await offchainVerifiedTaskPlugin.getStatusPerSubmitter(
        1,
        addr2.address
      );
      expect(status).to.eql(0);
      const tx = offchainVerifiedTaskPlugin
        .connect(verifier)
        .finalizeFor(1, addr2.address);

      await expect(tx)
        .to.emit(offchainVerifiedTaskPlugin, "TaskFinalized")
        .withArgs(1, addr2.address);

      const interactions = await dao.getInteractionsPerUser(addr2.address);
      expect(interactions.toString()).to.eql("1");

      status = await offchainVerifiedTaskPlugin.getStatusPerSubmitter(
        1,
        addr2.address
      );
      expect(status).to.eql(3);
    });

    it("Should return correctly hasCompletedTheTask", async () => {
      await expect(
        await offchainVerifiedTaskPlugin.hasCompletedTheTask(addr2.address, 1)
      ).to.be.true;
      await expect(
        await offchainVerifiedTaskPlugin.hasCompletedTheTask(addr2.address, 2)
      ).to.be.false;
      await expect(
        await offchainVerifiedTaskPlugin.hasCompletedTheTask(addr3.address, 1)
      ).to.be.false;
    });
  });
});
