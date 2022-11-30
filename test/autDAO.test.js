const { expect } = require("chai");
const { ethers } = require("hardhat");
const URL = "https://someurl.com";
let autDAO;
let autID;
let deployer;
let admin1;
let admin2;

describe("AutDAO", function () {
  describe("deployment", function () {
    before(async function () {
      [dep, notAMem, ...addrs] = await ethers.getSigners();
      deployer = dep;

      const AutID = await ethers.getContractFactory("AutID");
      autID = await AutID.deploy();
      await autID.deployed();
    });
    it("Should fail if arguemnts are incorret", async function () {
      const AutDAO = await ethers.getContractFactory("AutDAO");
      await expect(
        AutDAO.deploy(
          deployer.address,
          autID.address,
          7,
          URL,
          10
        )
      ).to.be.revertedWith("Market invalid");

      await expect(
        AutDAO.deploy(
          deployer.address,
          autID.address,
          2,
          "",
          10
        )
      ).to.be.revertedWith("Missing Metadata URL");

      await expect(
        AutDAO.deploy(
          deployer.address,
          autID.address,
          2,
          URL,
          0
        )
      ).to.be.revertedWith("Commitment should be between 1 and 10");
      await expect(
        AutDAO.deploy(
          deployer.address,
          autID.address,
          2,
          URL,
          11
        )
      ).to.be.revertedWith("Commitment should be between 1 and 10");
    });
    it("Should deploy an AutDAO", async function () {
      const AutDAO = await ethers.getContractFactory("AutDAO");
      autDAO = await AutDAO.deploy(
        deployer.address,
        autID.address,
        1,
        URL,
        10
      );

      await autDAO.deployed();

      expect(autDAO.address).to.not.be.null;
    });
  });
  describe("Manage URLs", async () => {
    before(async function () {
     
      const AutDAO = await ethers.getContractFactory("AutDAO");
      autDAO = await AutDAO.deploy(
        deployer.address,
        autID.address,
        1,
        URL,
        10
      );
      await autDAO.deployed();
    });
    it("Should return false when URL list is empty", async () => {
      expect(await autDAO.isURLListed("")).to.equal(false);
    });
    it("Should add an URL to the list", async () => {
      await autDAO.addURL("https://test1.test");
      const urls = await autDAO.getURLs();

      expect(await autDAO.isURLListed("https://test1.test")).to.equal(
        true
      );
      expect(urls.length).to.equal(1);
      expect(urls[0]).to.equal("https://test1.test");
    });
    it("Should remove an URL from the list", async () => {
      await autDAO.removeURL("https://test1.test");
      const urls = await autDAO.getURLs();

      expect(await autDAO.isURLListed("https://test1.test")).to.equal(
        false
      );
      expect(urls.length).to.equal(0);
    });
    it("Should add 3 more URLs to the list", async () => {
      await autDAO.addURL("https://test1.test");
      await autDAO.addURL("https://test2.test");
      await autDAO.addURL("https://test3.test");
      const urls = await autDAO.getURLs();

      expect(await autDAO.isURLListed("https://test1.test")).to.equal(
        true
      );
      expect(await autDAO.isURLListed("https://test2.test")).to.equal(
        true
      );
      expect(await autDAO.isURLListed("https://test3.test")).to.equal(
        true
      );
      expect(urls.length).to.equal(3);
      expect(urls[0]).to.equal("https://test1.test");
      expect(urls[1]).to.equal("https://test2.test");
      expect(urls[2]).to.equal("https://test3.test");
    });
    it("Should not allow adding already existing URL to the list", async () => {
      await expect(autDAO.addURL("https://test2.test")).to.be.revertedWith(
        "url already exists"
      );
    });
    it("Should return false when URL is not listed", async () => {
      expect(await autDAO.isURLListed("https://test4.test")).to.equal(
        false
      );
      expect(await autDAO.isURLListed("")).to.equal(false);
    });
    it("Should not allow removing of non existing URL", async () => {
      await expect(
        autDAO.removeURL("https://test4.test")
      ).to.be.revertedWith("url doesnt exist");
      await expect(autDAO.removeURL("")).to.be.revertedWith(
        "url doesnt exist"
      );
    });
    it("Should remove one of the URLs from the list", async () => {
      await autDAO.removeURL("https://test2.test");
      const urls = await autDAO.getURLs();

      expect(await autDAO.isURLListed("https://test1.test")).to.equal(
        true
      );
      expect(await autDAO.isURLListed("https://test2.test")).to.equal(
        false
      );
      expect(await autDAO.isURLListed("https://test3.test")).to.equal(
        true
      );
      expect(urls.length).to.equal(2);
      expect(urls[0]).to.equal("https://test1.test");
      expect(urls[1]).to.equal("https://test3.test");
    });
    it("Should remove last URLs from the list", async () => {
      await autDAO.removeURL("https://test3.test");
      const urls = await autDAO.getURLs();

      expect(await autDAO.isURLListed("https://test1.test")).to.equal(
        true
      );
      expect(await autDAO.isURLListed("https://test2.test")).to.equal(
        false
      );
      expect(await autDAO.isURLListed("https://test3.test")).to.equal(
        false
      );
      expect(urls.length).to.equal(1);
      expect(urls[0]).to.equal("https://test1.test");
    });
    it("Should add one more URLs to the (end of) list", async () => {
      await autDAO.addURL("https://test2.test");
      const urls = await autDAO.getURLs();

      expect(await autDAO.isURLListed("https://test1.test")).to.equal(
        true
      );
      expect(await autDAO.isURLListed("https://test2.test")).to.equal(
        true
      );
      expect(await autDAO.isURLListed("https://test3.test")).to.equal(
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

      const AutDAO = await ethers.getContractFactory("AutDAO");
      autDAO = await AutDAO.deploy(
        deployer.address,
        autID.address,
        1,
        URL,
        10
      );

      await autDAO.deployed();

      expect(autDAO.address).to.not.be.null;
    });
    it("Should fail if the owner tries to add someone to the admin list if not a member", async () => {
      expect(autDAO.addAdmin(admin1.address)).to.be.revertedWith(
        "Not a member"
      );
    });
    it("Should succeed when the owner adds new admin", async () => {
      await (await autID
        .connect(admin1)
        .mint("username", "URL", 3, 10, autDAO.address)).wait();

      await autDAO.addAdmin(admin1.address);
      const admins = await autDAO.getAdmins();
      expect(admins.length).to.eq(2);
      expect(admins[0]).to.eq(deployer.address);
      expect(admins[1]).to.eq(admin1.address);
    });
    it("Should succeed when an admin adds new admins to the whitelist", async () => {
      await (await autID
        .connect(admin2)
        .mint("username1", "URL", 3, 10, autDAO.address)).wait();

      await autDAO.connect(admin1).addAdmin(admin2.address);
      const admins = await autDAO.getAdmins();
      expect(admins.length).to.eq(3);
      expect(admins[0]).to.eq(deployer.address);
      expect(admins[1]).to.eq(admin1.address);
      expect(admins[2]).to.eq(admin2.address);
    });
    it("Should remove an admin correctly", async () => {
      const a =await (await autDAO.connect(admin2).removeAdmin(admin1.address)).wait();
      const admins = await autDAO.getAdmins();
      expect(admins[0]).to.eq(deployer.address);
      expect(admins[1]).to.eq(ethers.constants.AddressZero);
      expect(admins[2]).to.eq(admin2.address);
      expect(await autDAO.isAdmin(admin2.address)).to.be.true;
      expect(await autDAO.isAdmin(admin1.address)).to.be.false;
    });
    it("Should fail if unlisted core team member attepts to add other core team members", async () => {
      await autDAO.connect(admin2).removeAdmin(admin1.address);
      expect(
        autDAO.connect(admin1).addAdmin(admin2.address)
      ).to.be.revertedWith("Only admin!");
    });
    it("Should fail if an admin tries to add someone that's not a member to the admins", async () => {
      await autDAO.connect(admin2).removeAdmin(admin1.address);
      expect(
        autDAO.connect(admin1).addAdmin(admin2.address)
      ).to.be.revertedWith("Only admin!");
    });
  });
});
