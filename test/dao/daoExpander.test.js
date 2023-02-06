const { expect } = require("chai");
const { ethers } = require("hardhat");
const URL = "https://someurl.com";
let daoExpander;
let dao;
let daoTypes;
let sWLegacyMembershipChecker;
let autID;
let deployer;
let admin1;
let admin2;
let pluginRegistry;

describe("DAOExpander", function () {
  describe("deployment", function () {
    before(async function () {
      [dep, notAMem, ...addrs] = await ethers.getSigners();
      deployer = dep;

      const AutID = await ethers.getContractFactory("AutID");
      autID = await AutID.deploy();
      await autID.deployed();

      const DAO = await ethers.getContractFactory("SWLegacyDAO");
      dao = await DAO.deploy();
      await dao.deployed();
      await dao.addMember(deployer.address);

      const DAOTypes = await ethers.getContractFactory("DAOTypes");
      daoTypes = await DAOTypes.deploy();
      await daoTypes.deployed();

      const SWLegacyMembershipChecker = await ethers.getContractFactory(
        "SWLegacyMembershipChecker"
      );

      sWLegacyMembershipChecker = await SWLegacyMembershipChecker.deploy();
      await sWLegacyMembershipChecker.deployed();

      daoTypes.addNewMembershipChecker(sWLegacyMembershipChecker.address);
      const PluginRegistryFactory = await ethers.getContractFactory("PluginRegistry");
      pluginRegistry = await PluginRegistryFactory.deploy();

    });
    it("Should fail if arguemnts are incorret", async function () {
      const DAOExpander = await ethers.getContractFactory("DAOExpander");
      await expect(
        DAOExpander.deploy(
          deployer.address,
          autID.address,
          ethers.constants.AddressZero,
          1,
          dao.address,
          1,
          URL,
          10,
          pluginRegistry.address

        )
      ).to.be.revertedWith("Missing DAO Types address");
      await expect(
        DAOExpander.deploy(
          deployer.address,
          autID.address,
          daoTypes.address,
          7,
          dao.address,
          1,
          URL,
          10,
          pluginRegistry.address

        )
      ).to.be.revertedWith("Invalid membership type");
      await expect(
        DAOExpander.deploy(
          deployer.address,
          autID.address,
          daoTypes.address,
          1,
          ethers.constants.AddressZero,
          1,
          URL,
          10,
          pluginRegistry.address

        )
      ).to.be.revertedWith("Missing DAO Address");
      await expect(
        DAOExpander.deploy(
          deployer.address,
          autID.address,
          daoTypes.address,
          1,
          dao.address,
          7,
          URL,
          10,
          pluginRegistry.address
        )
      ).to.be.revertedWith("Market invalid");

      await expect(
        DAOExpander.deploy(
          deployer.address,
          autID.address,
          daoTypes.address,
          1,
          dao.address,
          2,
          "",
          10,
          pluginRegistry.address

        )
      ).to.be.revertedWith("Missing Metadata URL");

      await expect(
        DAOExpander.deploy(
          deployer.address,
          autID.address,
          daoTypes.address,
          1,
          dao.address,
          2,
          URL,
          0,
          pluginRegistry.address

        )
      ).to.be.revertedWith("Commitment should be between 1 and 10");
      await expect(
        DAOExpander.deploy(
          deployer.address,
          autID.address,
          daoTypes.address,
          1,
          dao.address,
          2,
          URL,
          11,
          pluginRegistry.address

        )
      ).to.be.revertedWith("Commitment should be between 1 and 10");
    });
    it("Should deploy a DAOExpander", async function () {
      const DAOExpander = await ethers.getContractFactory("DAOExpander");
      daoExpander = await DAOExpander.deploy(
        deployer.address,
        autID.address,
        daoTypes.address,
        1,
        dao.address,
        1,
        URL,
        10,
        pluginRegistry.address

      );

      await daoExpander.deployed();

      expect(daoExpander.address).to.not.be.null;
    });
  });
  describe("Manage URLs", async () => {
    before(async function () {
      const Community = await ethers.getContractFactory("SWLegacyDAO");
      community = await Community.deploy();
      await community.deployed();
      await community.addMember(deployer.address);

      const DAOTypes = await ethers.getContractFactory("DAOTypes");
      daoTypes = await DAOTypes.deploy();
      await daoTypes.deployed();

      const SWLegacyMembershipChecker = await ethers.getContractFactory(
        "SWLegacyMembershipChecker"
      );

      sWLegacyMembershipChecker = await SWLegacyMembershipChecker.deploy();
      await sWLegacyMembershipChecker.deployed();

      await (await daoTypes.addNewMembershipChecker(sWLegacyMembershipChecker.address)).wait();

      const DAOExpander = await ethers.getContractFactory("DAOExpander");
      daoExpander = await DAOExpander.deploy(
        deployer.address,
        autID.address,
        daoTypes.address,
        1,
        dao.address,
        1,
        URL,
        10,
        pluginRegistry.address
      );
      await daoExpander.deployed();
    });
    it("Should return false when URL list is empty", async () => {
      expect(await daoExpander.isURLListed("")).to.equal(false);
    });
    it("Should add an URL to the list", async () => {
      await daoExpander.addURL("https://test1.test");
      const urls = await daoExpander.getURLs();

      expect(await daoExpander.isURLListed("https://test1.test")).to.equal(
        true
      );
      expect(urls.length).to.equal(1);
      expect(urls[0]).to.equal("https://test1.test");
    });
    it("Should remove an URL from the list", async () => {
      await daoExpander.removeURL("https://test1.test");
      const urls = await daoExpander.getURLs();

      expect(await daoExpander.isURLListed("https://test1.test")).to.equal(
        false
      );
      expect(urls.length).to.equal(0);
    });
    it("Should add 3 more URLs to the list", async () => {
      await daoExpander.addURL("https://test1.test");
      await daoExpander.addURL("https://test2.test");
      await daoExpander.addURL("https://test3.test");
      const urls = await daoExpander.getURLs();

      expect(await daoExpander.isURLListed("https://test1.test")).to.equal(
        true
      );
      expect(await daoExpander.isURLListed("https://test2.test")).to.equal(
        true
      );
      expect(await daoExpander.isURLListed("https://test3.test")).to.equal(
        true
      );
      expect(urls.length).to.equal(3);
      expect(urls[0]).to.equal("https://test1.test");
      expect(urls[1]).to.equal("https://test2.test");
      expect(urls[2]).to.equal("https://test3.test");
    });
    it("Should not allow adding already existing URL to the list", async () => {
      await expect(daoExpander.addURL("https://test2.test")).to.be.revertedWith(
        "url already exists"
      );
    });
    it("Should return false when URL is not listed", async () => {
      expect(await daoExpander.isURLListed("https://test4.test")).to.equal(
        false
      );
      expect(await daoExpander.isURLListed("")).to.equal(false);
    });
    it("Should not allow removing of non existing URL", async () => {
      await expect(
        daoExpander.removeURL("https://test4.test")
      ).to.be.revertedWith("url doesnt exist");
      await expect(daoExpander.removeURL("")).to.be.revertedWith(
        "url doesnt exist"
      );
    });
    it("Should remove one of the URLs from the list", async () => {
      await daoExpander.removeURL("https://test2.test");
      const urls = await daoExpander.getURLs();

      expect(await daoExpander.isURLListed("https://test1.test")).to.equal(
        true
      );
      expect(await daoExpander.isURLListed("https://test2.test")).to.equal(
        false
      );
      expect(await daoExpander.isURLListed("https://test3.test")).to.equal(
        true
      );
      expect(urls.length).to.equal(2);
      expect(urls[0]).to.equal("https://test1.test");
      expect(urls[1]).to.equal("https://test3.test");
    });
    it("Should remove last URLs from the list", async () => {
      await daoExpander.removeURL("https://test3.test");
      const urls = await daoExpander.getURLs();

      expect(await daoExpander.isURLListed("https://test1.test")).to.equal(
        true
      );
      expect(await daoExpander.isURLListed("https://test2.test")).to.equal(
        false
      );
      expect(await daoExpander.isURLListed("https://test3.test")).to.equal(
        false
      );
      expect(urls.length).to.equal(1);
      expect(urls[0]).to.equal("https://test1.test");
    });
    it("Should add one more URLs to the (end of) list", async () => {
      await daoExpander.addURL("https://test2.test");
      const urls = await daoExpander.getURLs();

      expect(await daoExpander.isURLListed("https://test1.test")).to.equal(
        true
      );
      expect(await daoExpander.isURLListed("https://test2.test")).to.equal(
        true
      );
      expect(await daoExpander.isURLListed("https://test3.test")).to.equal(
        false
      );
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

      const AutID = await ethers.getContractFactory("AutID");
      autID = await AutID.deploy();
      await autID.deployed();

      const DAO = await ethers.getContractFactory("SWLegacyDAO");
      dao = await DAO.deploy();
      await dao.deployed();
      await dao.addMember(deployer.address);

      const DAOTypes = await ethers.getContractFactory("DAOTypes");
      daoTypes = await DAOTypes.deploy();
      await daoTypes.deployed();

      const SWLegacyMembershipChecker = await ethers.getContractFactory(
        "SWLegacyMembershipChecker"
      );

      sWLegacyMembershipChecker = await SWLegacyMembershipChecker.deploy();
      await sWLegacyMembershipChecker.deployed();

      await (await daoTypes.addNewMembershipChecker(sWLegacyMembershipChecker.address)).wait();

      const DAOExpander = await ethers.getContractFactory("DAOExpander");
      daoExpander = await DAOExpander.deploy(
        deployer.address,
        autID.address,
        daoTypes.address,
        1,
        dao.address,
        1,
        URL,
        10,
        pluginRegistry.address
      );

      await daoExpander.deployed();

      expect(daoExpander.address).to.not.be.null;
    });
    it("Should fail if the owner tries to add someone to the admin list if not a member", async () => {
      expect(daoExpander.addAdmin(admin1.address)).to.be.revertedWith(
        "Not a member"
      );
    });
    it("Should succeed when the owner adds new admin", async () => {
      await (await dao.addMember(admin1.address)).wait();
      await (await autID
        .connect(admin1)
        .mint("username", "URL", 3, 10, daoExpander.address)).wait();

      await daoExpander.addAdmin(admin1.address);
      const admins = await daoExpander.getAdmins();
      expect(admins.length).to.eq(2);
      expect(admins[0]).to.eq(deployer.address);
      expect(admins[1]).to.eq(admin1.address);
    });
    it("Should succeed when an admin adds new admins to the whitelist", async () => {
      await (await dao.addMember(admin2.address)).wait();
      await (await autID
        .connect(admin2)
        .mint("username1", "URL", 3, 10, daoExpander.address)).wait();

      await daoExpander.connect(admin1).addAdmin(admin2.address);
      const admins = await daoExpander.getAdmins();
      expect(admins.length).to.eq(3);
      expect(admins[0]).to.eq(deployer.address);
      expect(admins[1]).to.eq(admin1.address);
      expect(admins[2]).to.eq(admin2.address);
    });
    it("Should remove an admin correctly", async () => {
      const a = await (await daoExpander.connect(admin2).removeAdmin(admin1.address)).wait();
      const admins = await daoExpander.getAdmins();
      expect(admins[0]).to.eq(deployer.address);
      expect(admins[1]).to.eq(ethers.constants.AddressZero);
      expect(admins[2]).to.eq(admin2.address);
      expect(await daoExpander.isAdmin(admin2.address)).to.be.true;
      expect(await daoExpander.isAdmin(admin1.address)).to.be.false;
    });
    it("Should fail if unlisted core team member attepts to add other core team members", async () => {
      await daoExpander.connect(admin2).removeAdmin(admin1.address);
      expect(
        daoExpander.connect(admin1).addAdmin(admin2.address)
      ).to.be.revertedWith("Only admin!");
    });
    it("Should fail if an admin tries to add someone that's not a member to the admins", async () => {
      await daoExpander.connect(admin2).removeAdmin(admin1.address);
      expect(
        daoExpander.connect(admin1).addAdmin(admin2.address)
      ).to.be.revertedWith("Only admin!");
    });
  });
});
