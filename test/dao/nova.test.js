const { expect } = require("chai");
const { ethers } = require("hardhat");
const URL = "https://someurl.com";
let nova;
let autID;
let deployer;
let admin1;
let admin2;
let pluginRegistry;

describe("Nova", function () {
  describe("deployment", function () {
    before(async function () {

      const ModuleRegistryFactory = await ethers.getContractFactory("ModuleRegistry");
      const moduleRegistry = await ModuleRegistryFactory.deploy();
  
      const PluginRegistry = await ethers.getContractFactory(
        "PluginRegistry"
      );
      pluginRegistry = await PluginRegistry.deploy(moduleRegistry.address);

      [dep, notAMem, ...addrs] = await ethers.getSigners();
      deployer = dep;

      const AutID = await ethers.getContractFactory("AutID");
      autID = await AutID.deploy();
      await autID.deployed();
    });
    it("Should fail if arguemnts are incorret", async function () {
      const Nova = await ethers.getContractFactory("Nova");
      await expect(
        Nova.deploy(deployer.address, autID.address, 7, URL, 10, pluginRegistry.address)
      ).to.be.revertedWith("invalid market");

      await expect(
        Nova.deploy(deployer.address, autID.address, 2, "", 10, pluginRegistry.address)
      ).to.be.revertedWith("invalid url");

      await expect(
        Nova.deploy(deployer.address, autID.address, 2, URL, 0, pluginRegistry.address)
      ).to.be.revertedWith("invalid commitment");
      await expect(
        Nova.deploy(deployer.address, autID.address, 2, URL, 11, pluginRegistry.address)
      ).to.be.revertedWith("invalid commitment");

      await expect(
        Nova.deploy(deployer.address, autID.address, 2, URL, 7, ethers.constants.AddressZero)
      ).to.be.revertedWith("invalid pluginRegistry");
    });
    it("Should deploy an Nova", async function () {
      const Nova = await ethers.getContractFactory("Nova");
      nova = await Nova.deploy(
        deployer.address,
        autID.address,
        1,
        URL,
        10,
        pluginRegistry.address
      );

      await nova.deployed();

      expect(nova.address).to.not.be.null;
    });
  });
  describe("Manage URLs", async () => {
    before(async function () {
      const ModuleRegistryFactory = await ethers.getContractFactory("ModuleRegistry");
      const moduleRegistry = await ModuleRegistryFactory.deploy();

      const PluginRegistryFactory = await ethers.getContractFactory(
        "PluginRegistry"
      );
      pluginRegistry = await PluginRegistryFactory.deploy(moduleRegistry.address);

      const Nova = await ethers.getContractFactory("Nova");
      nova = await Nova.deploy(deployer.address, autID.address, 1, URL, 10, pluginRegistry.address);
      await nova.deployed();
    });
    it("Should return false when URL list is empty", async () => {
      expect(await nova.isURLListed("")).to.equal(false);
    });
    it("Should add an URL to the list", async () => {
      await nova.addURL("https://test1.test");
      const urls = await nova.getURLs();

      expect(await nova.isURLListed("https://test1.test")).to.equal(true);
      expect(urls.length).to.equal(1);
      expect(urls[0]).to.equal("https://test1.test");
    });
    it("Should remove an URL from the list", async () => {
      await nova.removeURL("https://test1.test");
      const urls = await nova.getURLs();

      expect(await nova.isURLListed("https://test1.test")).to.equal(false);
      expect(urls.length).to.equal(0);
    });
    it("Should add 3 more URLs to the list", async () => {
      await nova.addURL("https://test1.test");
      await nova.addURL("https://test2.test");
      await nova.addURL("https://test3.test");
      const urls = await nova.getURLs();

      expect(await nova.isURLListed("https://test1.test")).to.equal(true);
      expect(await nova.isURLListed("https://test2.test")).to.equal(true);
      expect(await nova.isURLListed("https://test3.test")).to.equal(true);
      expect(urls.length).to.equal(3);
      expect(urls[0]).to.equal("https://test1.test");
      expect(urls[1]).to.equal("https://test2.test");
      expect(urls[2]).to.equal("https://test3.test");
    });
    it("Should not allow adding already existing URL to the list", async () => {
      await expect(nova.addURL("https://test2.test")).to.be.revertedWith(
        "url already exists"
      );
    });
    it("Should return false when URL is not listed", async () => {
      expect(await nova.isURLListed("https://test4.test")).to.equal(false);
      expect(await nova.isURLListed("")).to.equal(false);
    });
    it("Should not allow removing of non existing URL", async () => {
      await expect(nova.removeURL("https://test4.test")).to.be.revertedWith(
        "url doesnt exist"
      );
      await expect(nova.removeURL("")).to.be.revertedWith("url doesnt exist");
    });
    it("Should remove one of the URLs from the list", async () => {
      await nova.removeURL("https://test2.test");
      const urls = await nova.getURLs();

      expect(await nova.isURLListed("https://test1.test")).to.equal(true);
      expect(await nova.isURLListed("https://test2.test")).to.equal(false);
      expect(await nova.isURLListed("https://test3.test")).to.equal(true);
      expect(urls.length).to.equal(2);
      expect(urls[0]).to.equal("https://test1.test");
      expect(urls[1]).to.equal("https://test3.test");
    });
    it("Should remove last URLs from the list", async () => {
      await nova.removeURL("https://test3.test");
      const urls = await nova.getURLs();

      expect(await nova.isURLListed("https://test1.test")).to.equal(true);
      expect(await nova.isURLListed("https://test2.test")).to.equal(false);
      expect(await nova.isURLListed("https://test3.test")).to.equal(false);
      expect(urls.length).to.equal(1);
      expect(urls[0]).to.equal("https://test1.test");
    });
    it("Should add one more URLs to the (end of) list", async () => {
      await nova.addURL("https://test2.test");
      const urls = await nova.getURLs();

      expect(await nova.isURLListed("https://test1.test")).to.equal(true);
      expect(await nova.isURLListed("https://test2.test")).to.equal(true);
      expect(await nova.isURLListed("https://test3.test")).to.equal(false);
      expect(urls.length).to.equal(2);
      expect(urls[0]).to.equal("https://test1.test");
      expect(urls[1]).to.equal("https://test2.test");
    });
  });
  describe("Admins", async () => {
    before(async function () {
      [dep, notAMem, ad1, ad2, ...addrs] = await ethers.getSigners();
      deployer = dep;
      admin1 = ad1;
      admin2 = ad2;
      const ModuleRegistryFactory = await ethers.getContractFactory("ModuleRegistry");
      const moduleRegistry = await ModuleRegistryFactory.deploy();

      const PluginRegistryFactory = await ethers.getContractFactory(
        "PluginRegistry"
      );
      pluginRegistry = await PluginRegistryFactory.deploy(moduleRegistry.address);

      const AutID = await ethers.getContractFactory("AutID");
      autID = await AutID.deploy();
      await autID.deployed();

      const Nova = await ethers.getContractFactory("Nova");
      nova = await Nova.deploy(deployer.address, autID.address, 1, URL, 10, pluginRegistry.address);

      await nova.deployed();

      expect(nova.address).to.not.be.null;
    });
    it("Should fail if the owner tries to add someone to the admin list if not a member", async () => {
      expect(nova.addAdmin(admin1.address)).to.be.revertedWith(
        "Not a member"
      );
    });
    it("Should succeed when the owner adds new admin", async () => {
      await (
        await autID
          .connect(admin1)
          .mint("username", "URL", 3, 10, nova.address)
      ).wait();

      await nova.addAdmin(admin1.address);
      const admins = await nova.getAdmins();
      expect(admins.length).to.eq(2);
      expect(admins[0]).to.eq(deployer.address);
      expect(admins[1]).to.eq(admin1.address);
    });
    it("Should succeed when an admin adds new admins to the whitelist", async () => {
      await (
        await autID
          .connect(admin2)
          .mint("username1", "URL", 3, 10, nova.address)
      ).wait();

      await nova.connect(admin1).addAdmin(admin2.address);
      const admins = await nova.getAdmins();
      expect(admins.length).to.eq(3);
      expect(admins[0]).to.eq(deployer.address);
      expect(admins[1]).to.eq(admin1.address);
      expect(admins[2]).to.eq(admin2.address);
    });
    it("Should remove an admin correctly", async () => {
      const a = await (
        await nova.connect(admin2).removeAdmin(admin1.address)
      ).wait();
      const admins = await nova.getAdmins();
      expect(admins[0]).to.eq(deployer.address);
      expect(admins[1]).to.eq(ethers.constants.AddressZero);
      expect(admins[2]).to.eq(admin2.address);
      expect(await nova.isAdmin(admin2.address)).to.be.true;
      expect(await nova.isAdmin(admin1.address)).to.be.false;
    });
    it("Should fail if unlisted core team member attepts to add other core team members", async () => {
      await nova.connect(admin2).removeAdmin(admin1.address);
      expect(
        nova.connect(admin1).addAdmin(admin2.address)
      ).to.be.revertedWith("Only admin!");
    });
    it("Should fail if an admin tries to add someone that's not a member to the admins", async () => {
      await nova.connect(admin2).removeAdmin(admin1.address);
      expect(
        nova.connect(admin1).addAdmin(admin2.address)
      ).to.be.revertedWith("Only admin!");
    });
  });
});
