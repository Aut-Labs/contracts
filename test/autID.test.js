const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");
const URL = "https://someurl.com";
const username = "username";
const username1 = "username1";

let daoExpander;
let daoExpander2;
let dao;
let dao2;
let autID;
let daoTypes;
let sWLegacyMembershipChecker;
let deployer;

describe("AutID", function () {
  describe("mint", function () {
    before(async function () {
      [dep, notAMem, ...addrs] = await ethers.getSigners();
      deployer = dep;

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
    });
    beforeEach(async function () {
      [
        deployer,
        daoMember,
        daoMember2,
        user1,
        user2,
        user3,
        ...addrs
      ] = await ethers.getSigners();

      const AutID = await ethers.getContractFactory("AutID");
      autID = await AutID.deploy();

      autID = await upgrades.deployProxy(AutID, [], { from: deployer });
      await autID.deployed();

      const DAOExpander = await ethers.getContractFactory("DAOExpander");

      daoExpander = await DAOExpander.deploy(
        deployer.address,
        autID.address,
        daoTypes.address,
        1,
        dao.address,
        1,
        URL,
        5
      );
      await daoExpander.deployed();

      await dao.addMember(daoMember.address);
      await dao.addMember(daoMember2.address);
    });
    it("Should fail if arguemnts are incorret", async function () {
      await expect(
        autID.mint(username, URL, 4, 8, daoExpander.address)
      ).to.revertedWith("Role must be between 1 and 3");
      await expect(
        autID.mint(username, URL, 3, 0, daoExpander.address)
      ).to.revertedWith("Commitment should be between 1 and 10");
      await expect(
        autID.mint(username, URL, 3, 11, daoExpander.address)
      ).to.revertedWith("Commitment should be between 1 and 10");

      await expect(
        autID.mint(username, URL, 3, 8, ethers.constants.AddressZero)
      ).to.revertedWith("Missing DAO Expander");
    });
    it("Should fail if the signer is not a member of the DAO", async function () {
      await expect(
        autID.connect(user1).mint(username, URL, 3, 5, daoExpander.address)
      ).to.be.revertedWith("Not a member of this DAO!");
    });
    it("Should mint a AutID if singer is a member of the original DAO", async function () {
      const events = await (
        await autID
          .connect(daoMember)
          .mint(username, URL, 3, 10, daoExpander.address)
      ).wait();
      const swCreatedEvent = events.events.find(
        (event) => event.event == "AutIDCreated"
      );
      const tokenId = swCreatedEvent.args["tokenID"].toString();

      const sw = await autID.getAutIDByOwner(daoMember.address);
      expect(tokenId).to.eq(sw.toString());

      const swComs = await autID.getHolderDAOs(daoMember.address);
      expect(swComs).not.to.be.undefined;

      const comData = await autID.getMembershipData(
        daoMember.address,
        daoExpander.address
      );

      const url = await autID.tokenURI(tokenId);
      const swUsername = await autID.autIDUsername(username);

      expect(url).to.eq(URL);
      expect(swUsername).to.eq(daoMember.address);
      expect(swComs.length).to.eq(1);
      expect(comData["daoExpanderAddress"]).to.eq(daoExpander.address);
      expect(comData["role"].toString()).to.eq("3");
      expect(comData["commitment"].toString()).to.eq("10");
      expect(await daoExpander.isMemberOfOriginalDAO(daoMember.address)).to.eq(
        true
      );
      expect(await daoExpander.isMemberOfExtendedDAO(daoMember.address)).to.eq(
        true
      );
    });
    it("Should not mint an AutID twice", async function () {
      await (
        await autID
          .connect(daoMember)
          .mint(username, URL, 3, 10, daoExpander.address)
      ).wait();
      await expect(
        autID.connect(daoMember).mint(username, URL, 3, 10, daoExpander.address)
      ).to.be.revertedWith(
        "AutID: There is AutID already registered for this address."
      );
    });
    it("Should fail if the username is taken", async function () {
      await (
        await autID
          .connect(daoMember)
          .mint(username, URL, 3, 10, daoExpander.address)
      ).wait();
      await expect(
        autID.connect(daoMember).mint(username, URL, 3, 10, daoExpander.address)
      ).to.be.revertedWith(
        "AutID: There is AutID already registered for this address."
      );
    });
  });
  describe("joinDAO", function () {
    before(async function () {
      [dep, notAMem, ...addrs] = await ethers.getSigners();
      deployer = dep;

      const DAO = await ethers.getContractFactory("SWLegacyDAO");
      dao = await DAO.deploy();
      await dao.deployed();
      await dao.addMember(deployer.address);

      dao2 = await DAO.deploy();
      await dao2.deployed();
      await dao2.addMember(deployer.address);

      const DAOTypes = await ethers.getContractFactory("DAOTypes");
      daoTypes = await DAOTypes.deploy();
      await daoTypes.deployed();

      const SWLegacyMembershipChecker = await ethers.getContractFactory(
        "SWLegacyMembershipChecker"
      );

      sWLegacyMembershipChecker = await SWLegacyMembershipChecker.deploy();
      await sWLegacyMembershipChecker.deployed();

      daoTypes.addNewMembershipChecker(sWLegacyMembershipChecker.address);
    });
    beforeEach(async function () {
      [
        deployer,
        daoMember,
        daoMember2,
        user1,
        user2,
        user3,
        ...addrs
      ] = await ethers.getSigners();

      const AutID = await ethers.getContractFactory("AutID");
      autID = await AutID.deploy();
      await autID.deployed();

      const DAOExpander = await ethers.getContractFactory("DAOExpander");

      daoExpander = await DAOExpander.deploy(
        deployer.address,
        autID.address,
        daoTypes.address,
        1,
        dao.address,
        1,
        URL,
        5
      );
      await daoExpander.deployed();
      daoExpander2 = await DAOExpander.deploy(
        deployer.address,
        autID.address,
        daoTypes.address,
        1,
        dao2.address,
        1,
        URL,
        5
      );
      await daoExpander2.deployed();

      await dao.addMember(daoMember.address);
      await dao.addMember(daoMember2.address);
      await dao2.addMember(daoMember2.address);

      await (
        await autID
          .connect(daoMember)
          .mint(username, URL, 3, 5, daoExpander.address)
      ).wait();
    });
    it("Should fail if arguemnts are incorret", async function () {
      await expect(autID.joinDAO(4, 8, daoExpander.address)).to.revertedWith(
        "Role must be between 1 and 3"
      );
      await expect(autID.joinDAO(3, 0, daoExpander.address)).to.revertedWith(
        "Commitment should be between 1 and 10"
      );
      await expect(autID.joinDAO(3, 11, daoExpander.address)).to.revertedWith(
        "Commitment should be between 1 and 10"
      );
      await expect(
        autID.joinDAO(3, 8, ethers.constants.AddressZero)
      ).to.revertedWith("Missing DAO Expander");
    });
    it("Should fail if there's no AutID minted for the signer", async function () {
      await expect(
        autID.connect(user2).joinDAO(3, 10, daoExpander2.address)
      ).to.be.revertedWith(
        "AutID: There is no AutID registered for this address."
      );
    });
    it("Should fail if the maximum commitment is reached", async function () {
      await expect(
        autID.connect(daoMember).joinDAO(3, 6, daoExpander2.address)
      ).to.be.revertedWith("Maximum commitment reached");
    });
    it("Should fail if the selected commitment is lower than DAO minimum", async function () {
      await expect(
        autID.connect(daoMember).joinDAO(3, 2, daoExpander2.address)
      ).to.be.revertedWith("Commitment lower than the DAOs min commitment");
    });
    it("Should fail if the signer is not a member of the DAO", async function () {
      await expect(
        autID.connect(daoMember).joinDAO(3, 5, daoExpander2.address)
      ).to.be.revertedWith("Not a member of this DAO!");
    });
    it("Should add the new Community to the AutID for original DAO member", async function () {
      await dao.addMember(daoMember2.address);

      await (
        await autID
          .connect(daoMember2)
          .mint(username1, URL, 3, 5, daoExpander.address)
      ).wait();

      const events = await (
        await autID.connect(daoMember2).joinDAO(2, 5, daoExpander2.address)
      ).wait();

      const communityJoinedEvent = events.events.find(
        (event) => event.event == "DAOJoined"
      );
      expect(communityJoinedEvent).not.to.be.undefined;

      const swComs = await autID.getHolderDAOs(daoMember2.address);
      expect(swComs).not.to.be.undefined;

      const comData1 = await autID.getMembershipData(
        daoMember2.address,
        daoExpander.address
      );

      const comData2 = await autID.getMembershipData(
        daoMember2.address,
        daoExpander2.address
      );
      expect(swComs.length).to.eq(2);
      expect(comData1["daoExpanderAddress"]).to.eq(daoExpander.address);
      expect(comData1["role"].toString()).to.eq("3");
      expect(comData1["commitment"].toString()).to.eq("5");
      expect(comData2["daoExpanderAddress"]).to.eq(daoExpander2.address);
      expect(comData2["role"].toString()).to.eq("2");
      expect(comData2["commitment"].toString()).to.eq("5");

      expect(
        await daoExpander2.isMemberOfOriginalDAO(daoMember2.address)
      ).to.eq(true);
      expect(
        await daoExpander2.isMemberOfExtendedDAO(daoMember2.address)
      ).to.eq(true);
    });
    it("Should not join one community twice", async function () {
      await expect(
        autID
          .connect(daoMember)
          .joinDAO(3, 10, daoExpander.address)
      ).to.be.revertedWith("Already a member");
    });
  });
  describe("transfer", function () {
    before(async function () {
      [dep, notAMem, ...addrs] = await ethers.getSigners();
      deployer = dep;

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
    });
    beforeEach(async function () {
      [deployer, autIDHolder1, autIDHolder2, ...addrs] =
        await ethers.getSigners();

      const AutID = await ethers.getContractFactory("AutID");
      autID = await AutID.deploy();
      await autID.deployed();

      const DAOExpander = await ethers.getContractFactory("DAOExpander");

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

      await dao.addMember(autIDHolder1.address);
      await (
        await autID
          .connect(autIDHolder1)
          .mint(username, URL, 3, 10, daoExpander.address)
      ).wait();
    });
    it("Should fail when transferring", async function () {
      await expect(
        autID
          .connect(autIDHolder1)
          .transferFrom(autIDHolder1.address, autIDHolder2.address, 0)
      ).to.revertedWith("AutID: AutID transfer disabled");
    });
  });
});
