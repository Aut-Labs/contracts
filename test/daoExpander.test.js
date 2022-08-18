const { expect } = require("chai");
const { ethers } = require("hardhat");
const URL = "https://someurl.com";
let daoExpander;
let dao;
let daoTypes;
let sWLegacyMembershipChecker;
let autID;
let deployer;

describe("DAOExpander", function () {
  describe("deployment", function () {
    before(async function () {
      [dep, notAMem, ...addrs] = await ethers.getSigners();
      deployer = dep;
      
      const AutID = await ethers.getContractFactory("AutID");
      autID = await AutID.deploy();
      await autID.deployed();

      const DAO = await ethers.getContractFactory("Tribute");
      dao = await DAO.deploy();
      await dao.deployed();
      await dao.addMember(deployer.address);

      const DAOTypes = await ethers.getContractFactory(
        "DAOTypes"
      );
      daoTypes = await DAOTypes.deploy();
      await daoTypes.deployed();

      const TributeMembershipChecker = await ethers.getContractFactory(
        "TributeMembershipChecker"
      );

      tributeMembershipChecker = await TributeMembershipChecker.deploy();
      await tributeMembershipChecker.deployed();

      daoTypes.addNewMembershipChecker(
        tributeMembershipChecker.address
      );
    });
    it("Should fail if arguemnts are incorret", async function () {
      const DAOExpander = await ethers.getContractFactory(
        "DAOExpander"
      );
      await expect(
        DAOExpander.deploy(
          deployer.address,
          autID.address,
          ethers.constants.AddressZero,
          1,
          dao.address,
          1,
          URL,
          10
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
          10
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
          10
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
          10
        )
      ).to.be.revertedWith("Invalid market");

      await expect(
        DAOExpander.deploy(
          deployer.address,
          autID.address,
          daoTypes.address,
          1,
          dao.address,
          2,
          "",
          10
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
          0
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
          11
        )
      ).to.be.revertedWith("Commitment should be between 1 and 10");
    });
    it("Should deploy a DAOExpander", async function () {
      const DAOExpander = await ethers.getContractFactory(
        "DAOExpander"
      );
      daoExpander = await DAOExpander.deploy(
        deployer.address,
        autID.address,
        daoTypes.address,
        1,
        dao.address,
        1,
        URL,
        10
      );

      await daoExpander.deployed();

      expect(daoExpander.address).to.not.be.null;
    });
  });
  describe("Manage URLs", async () => {
    before(async function () {
      const Community = await ethers.getContractFactory("Tribute");
      community = await Community.deploy();
      await community.deployed();
      await community.addMember(deployer.address);

      const DAOTypes = await ethers.getContractFactory(
        "DAOTypes"
      );
      daoTypes = await DAOTypes.deploy();
      await daoTypes.deployed();

      const TributeMembershipChecker = await ethers.getContractFactory(
        "TributeMembershipChecker"
      );

      tributeMembershipChecker = await TributeMembershipChecker.deploy();
      await tributeMembershipChecker.deployed();

      daoTypes.addNewMembershipChecker(
        tributeMembershipChecker.address
      );

      const DAOExpander = await ethers.getContractFactory(
        "DAOExpander"
      );
      daoExpander = await DAOExpander.deploy(
        deployer.address,
        autID.address,
        daoTypes.address,
        1,
        dao.address,
        1,
        URL,
        10
      );
      await daoExpander.deployed();
    });
    it("Should return false when URL list is empty", async () => {
      expect(await daoExpander.isURLListed("")).to.equal(false);
    });
    it("Should add an URL to the list", async () => {
      await daoExpander.addURL("https://test1.test");
      const urls = await daoExpander.getURLs();

      expect(
        await daoExpander.isURLListed("https://test1.test")
      ).to.equal(true);
      expect(urls.length).to.equal(1);
      expect(urls[0]).to.equal("https://test1.test");
    });
    it("Should remove an URL from the list", async () => {
      await daoExpander.removeURL("https://test1.test");
      const urls = await daoExpander.getURLs();

      expect(
        await daoExpander.isURLListed("https://test1.test")
      ).to.equal(false);
      expect(urls.length).to.equal(0);
    });
    it("Should add 3 more URLs to the list", async () => {
      await daoExpander.addURL("https://test1.test");
      await daoExpander.addURL("https://test2.test");
      await daoExpander.addURL("https://test3.test");
      const urls = await daoExpander.getURLs();

      expect(
        await daoExpander.isURLListed("https://test1.test")
      ).to.equal(true);
      expect(
        await daoExpander.isURLListed("https://test2.test")
      ).to.equal(true);
      expect(
        await daoExpander.isURLListed("https://test3.test")
      ).to.equal(true);
      expect(urls.length).to.equal(3);
      expect(urls[0]).to.equal("https://test1.test");
      expect(urls[1]).to.equal("https://test2.test");
      expect(urls[2]).to.equal("https://test3.test");
    });
    it("Should not allow adding already existing URL to the list", async () => {
      await expect(
        daoExpander.addURL("https://test2.test")
      ).to.be.revertedWith("url already exists");
    });
    it("Should return false when URL is not listed", async () => {
      expect(
        await daoExpander.isURLListed("https://test4.test")
      ).to.equal(false);
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

      expect(
        await daoExpander.isURLListed("https://test1.test")
      ).to.equal(true);
      expect(
        await daoExpander.isURLListed("https://test2.test")
      ).to.equal(false);
      expect(
        await daoExpander.isURLListed("https://test3.test")
      ).to.equal(true);
      expect(urls.length).to.equal(2);
      expect(urls[0]).to.equal("https://test1.test");
      expect(urls[1]).to.equal("https://test3.test");
    });
    it("Should remove last URLs from the list", async () => {
      await daoExpander.removeURL("https://test3.test");
      const urls = await daoExpander.getURLs();

      expect(
        await daoExpander.isURLListed("https://test1.test")
      ).to.equal(true);
      expect(
        await daoExpander.isURLListed("https://test2.test")
      ).to.equal(false);
      expect(
        await daoExpander.isURLListed("https://test3.test")
      ).to.equal(false);
      expect(urls.length).to.equal(1);
      expect(urls[0]).to.equal("https://test1.test");
    });
    it("Should add one more URLs to the (end of) list", async () => {
      await daoExpander.addURL("https://test2.test");
      const urls = await daoExpander.getURLs();

      expect(
        await daoExpander.isURLListed("https://test1.test")
      ).to.equal(true);
      expect(
        await daoExpander.isURLListed("https://test2.test")
      ).to.equal(true);
      expect(
        await daoExpander.isURLListed("https://test3.test")
      ).to.equal(false);
      expect(urls.length).to.equal(2);
      expect(urls[0]).to.equal("https://test1.test");
      expect(urls[1]).to.equal("https://test2.test");
    });
  });
});
