const { expect } = require("chai");
const { ethers } = require("hardhat");
const URL = "https://someurl.com";
const username = 'username';
const username1 = 'username1';

let communityExtension;
let communityExtension2;
let community;
let community2;
let autID;
let membershipTypes;
let sWLegacyMembershipChecker;
let deployer;

describe("AutID", function () {
  describe("mint", function () {
    before(async function () {
      [dep, notAMem, ...addrs] = await ethers.getSigners();
      deployer = dep;
      
      const Community = await ethers.getContractFactory("SWLegacyCommunity");
      community = await Community.deploy();
      await community.deployed();
      await community.addMember(deployer.address);

      const MembershipTypes = await ethers.getContractFactory(
        "MembershipTypes"
      );
      membershipTypes = await MembershipTypes.deploy();
      await membershipTypes.deployed();

      const SWLegacyMembershipChecker = await ethers.getContractFactory(
        "SWLegacyMembershipChecker"
      );

      sWLegacyMembershipChecker = await SWLegacyMembershipChecker.deploy();
      await sWLegacyMembershipChecker.deployed();

      membershipTypes.addNewMembershipExtension(
        sWLegacyMembershipChecker.address,
      );
    });
    beforeEach(async function () {
      [deployer, daoMember, daoMember2, onboarded, onboarded1, user1, user2, user3, ...addrs] =
        await ethers.getSigners();

      const AutID = await ethers.getContractFactory("AutID");
      autID = await AutID.deploy();
      await autID.deployed();

      const CommunityExtension = await ethers.getContractFactory(
        "CommunityExtension"
      );

      communityExtension = await CommunityExtension.deploy(
        deployer.address,
        autID.address,
        membershipTypes.address,
        1,
        community.address,
        1,
        URL,
        10
      );
      await communityExtension.deployed();

      await community.addMember(daoMember.address);
      await community.addMember(daoMember2.address);
      await communityExtension.passOnboarding([onboarded.address]);

    });
    it("Should fail if arguemnts are incorret", async function () {
      await expect(
        autID.mint(username, URL, 4, 8, communityExtension.address)
      ).to.revertedWith("Role must be between 1 and 3");
      await expect(
        autID.mint(username, URL, 3, 0, communityExtension.address)
      ).to.revertedWith("Commitment should be between 1 and 10");
      await expect(
        autID.mint(username, URL, 3, 11, communityExtension.address)
      ).to.revertedWith("Commitment should be between 1 and 10");

      await expect(
        autID.mint(username, URL, 3, 8, ethers.constants.AddressZero)
      ).to.revertedWith("Missing community extension");
    });
    it("Should fail if the signer is not a member of the DAO", async function () {
      await expect(
        autID.connect(user1).mint(username, URL, 3, 10, communityExtension.address)
      ).to.be.revertedWith("Not a member of this DAO!");
    });
    it("Should mint a AutID if singer is a member of the original DAO", async function () {
      const events = await (
        await autID
          .connect(daoMember)
          .mint(username, URL, 3, 10, communityExtension.address)
      ).wait();
      const swCreatedEvent = events.events.find(
        (event) => event.event == "AutIDCreated"
      );
      const tokenId = swCreatedEvent.args["tokenID"].toString();

      const sw = await autID.getAutIDByOwner(
        daoMember.address
      );
      expect(tokenId).to.eq(sw.toString());

      const swComs = await autID.getCommunities(
        daoMember.address
      );
      expect(swComs).not.to.be.undefined;

      const comData = await autID.getCommunityData(daoMember.address, communityExtension.address);

      const url = await autID.tokenURI(tokenId);
      const swUsername = await autID.autIDUsername(username);

      expect(url).to.eq(URL);
      expect(swUsername).to.eq(daoMember.address);
      expect(swComs.length).to.eq(1);
      expect(comData["communityExtension"]).to.eq(communityExtension.address);
      expect(comData["role"].toString()).to.eq("3");
      expect(comData["commitment"].toString()).to.eq("10");
      expect(await communityExtension.isMemberOfOriginalDAO(daoMember.address)).to.eq(true);
      expect(await communityExtension.isMemberOfExtendedDAO(daoMember.address)).to.eq(true);
    });
    it("Should not mint a SW NFTID twice", async function () {
      await (
        await autID
          .connect(daoMember)
          .mint(username, URL, 3, 10, communityExtension.address)
      ).wait();
      await expect(
        autID
          .connect(daoMember)
          .mint(username, URL, 3, 10, communityExtension.address)
      ).to.be.revertedWith(
        "AutID: There is AutID already registered for this address."
      );
    });
    it("Should fail if the username is taken", async function () {
      await (
        await autID
          .connect(daoMember)
          .mint(username, URL, 3, 10, communityExtension.address)
      ).wait();
      await expect(
        autID
          .connect(daoMember)
          .mint(username, URL, 3, 10, communityExtension.address)
      ).to.be.revertedWith(
        "AutID: There is AutID already registered for this address."
      );
    });
    it("Should mint a AutID in relation to the extended community if onboarding has passed", async function () {

      const events = await (
        await autID
          .connect(onboarded)
          .mint(username, URL, 3, 2, communityExtension.address)
      ).wait();

      const swCreatedEvent = events.events.find(
        (event) => event.event == "AutIDCreated"
      );
      const tokenId = swCreatedEvent.args["tokenID"].toString();

      const sw = await autID.getAutIDByOwner(
        onboarded.address
      );
      expect(tokenId).to.eq(sw.toString());

      const swComs = await autID.getCommunities(
        onboarded.address
      );
      expect(swComs).not.to.be.undefined;
      const comData = await autID.getCommunityData(onboarded.address, communityExtension.address);

      const url = await autID.tokenURI(tokenId);

      expect(url).to.eq(URL);
      expect(swComs.length).to.eq(1);
      expect(comData["communityExtension"]).to.eq(communityExtension.address);
      expect(comData["role"].toString()).to.eq("3");
      expect(comData["commitment"].toString()).to.eq("2");
      expect(await communityExtension.isMemberOfOriginalDAO(onboarded.address)).to.eq(false);
      expect(await communityExtension.isMemberOfExtendedDAO(onboarded.address)).to.eq(true);
    });
  });
  describe("joinCommunity", function () {
    before(async function () {
      [dep, notAMem, ...addrs] = await ethers.getSigners();
      deployer = dep;

      const Community = await ethers.getContractFactory("SWLegacyCommunity");
      community = await Community.deploy();
      await community.deployed();
      await community.addMember(deployer.address);

      community2 = await Community.deploy();
      await community2.deployed();

      await community2.addMember(deployer.address);

      const MembershipTypes = await ethers.getContractFactory(
        "MembershipTypes"
      );
      membershipTypes = await MembershipTypes.deploy();
      await membershipTypes.deployed();

      const SWLegacyMembershipChecker = await ethers.getContractFactory(
        "SWLegacyMembershipChecker"
      );

      sWLegacyMembershipChecker = await SWLegacyMembershipChecker.deploy();
      await sWLegacyMembershipChecker.deployed();

      membershipTypes.addNewMembershipExtension(
        sWLegacyMembershipChecker.address
      );
    });
    beforeEach(async function () {
      [deployer, daoMember, daoMember2, onboarded, onboarded2, user1, user2, user3, ...addrs] =
        await ethers.getSigners();

      const AutID = await ethers.getContractFactory("AutID");
      autID = await AutID.deploy();
      await autID.deployed();

      const CommunityExtension = await ethers.getContractFactory(
        "CommunityExtension"
      );

      communityExtension = await CommunityExtension.deploy(
        deployer.address,
        autID.address,
        membershipTypes.address,
        1,
        community.address,
        1,
        URL,
        10
      );
      await communityExtension.deployed();
      communityExtension2 = await CommunityExtension.deploy(
        deployer.address,
        autID.address,
        membershipTypes.address,
        1,
        community2.address,
        1,
        URL,
        10
      );
      await communityExtension2.deployed();

      await community.addMember(daoMember.address);
      await community.addMember(daoMember2.address);
      await community2.addMember(daoMember2.address);


      await communityExtension.passOnboarding([onboarded.address]);
      await communityExtension2.passOnboarding([onboarded.address]);

      await (
        await autID
          .connect(daoMember)
          .mint(username, URL, 3, 10, communityExtension.address)
      ).wait();
    });
    it("Should fail if arguemnts are incorret", async function () {
      await expect(
        autID.joinCommunity(4, 8, communityExtension.address)
      ).to.revertedWith("Role must be between 1 and 3");
      await expect(
        autID.joinCommunity(3, 0, communityExtension.address)
      ).to.revertedWith("Commitment should be between 1 and 10");
      await expect(
        autID.joinCommunity(3, 11, communityExtension.address)
      ).to.revertedWith("Commitment should be between 1 and 10");
      await expect(
        autID.joinCommunity(3, 8, ethers.constants.AddressZero)
      ).to.revertedWith("Missing community extension");
    });
    it("Should fail if there's no SW NFT ID minted for the signer", async function () {
      await expect(
        autID
          .connect(user2)
          .joinCommunity(3, 10, communityExtension2.address)
      ).to.be.revertedWith(
        "AutID: There is no AutID registered for this address."
      );
    });
    it("Should fail if the signer is not a member of the DAO", async function () {
      await expect(
        autID
          .connect(daoMember)
          .joinCommunity(3, 10, communityExtension2.address)
      ).to.be.revertedWith("Not a member of this DAO!");
    });
    it("Should add the new Community to the SW NFT ID for original DAO member", async function () {
      await community.addMember(daoMember2.address);

      await (
        await autID
          .connect(daoMember2)
          .mint(username1, URL, 3, 2, communityExtension.address)
      ).wait();

      const events = await (
        await autID
          .connect(daoMember2)
          .joinCommunity(2, 7, communityExtension2.address)
      ).wait();

      const communityJoinedEvent = events.events.find(
        (event) => event.event == "CommunityJoined"
      );
      expect(communityJoinedEvent).not.to.be.undefined;

      const swComs = await autID.getCommunities(
        daoMember2.address
      );
      expect(swComs).not.to.be.undefined;

      const comData1 = await autID.getCommunityData(
        daoMember2.address,
        communityExtension.address
      );

      const comData2 = await autID.getCommunityData(
        daoMember2.address,
        communityExtension2.address
      )
      expect(swComs.length).to.eq(2);
      expect(comData1["communityExtension"]).to.eq(communityExtension.address);
      expect(comData1["role"].toString()).to.eq("3");
      expect(comData1["commitment"].toString()).to.eq("2");
      expect(comData2["communityExtension"]).to.eq(
        communityExtension2.address
      );
      expect(comData2["role"].toString()).to.eq("2");
      expect(comData2["commitment"].toString()).to.eq("7");

      expect(await communityExtension2.isMemberOfOriginalDAO(daoMember2.address)).to.eq(true);
      expect(await communityExtension2.isMemberOfExtendedDAO(daoMember2.address)).to.eq(true);
    });
    it("Should add the new Community to the SW NFT ID for onboarded member", async function () {

      await (
        await autID
          .connect(onboarded)
          .mint(username1, URL, 3, 2, communityExtension.address)
      ).wait();

      const events = await (
        await autID
          .connect(onboarded)
          .joinCommunity(2, 7, communityExtension2.address)
      ).wait();

      const communityJoinedEvent = events.events.find(
        (event) => event.event == "CommunityJoined"
      );
      expect(communityJoinedEvent).not.to.be.undefined;

      const swComs = await autID.getCommunities(
        onboarded.address
      );
      expect(swComs).not.to.be.undefined;
      
      const comData1 = await autID.getCommunityData(
        onboarded.address,
        communityExtension.address
      )


      const comData2 = await autID.getCommunityData(
        onboarded.address,
        communityExtension2.address
      )
      
      expect(swComs.length).to.eq(2);
      expect(comData1["communityExtension"]).to.eq(communityExtension.address);
      expect(comData1["role"].toString()).to.eq("3");
      expect(comData1["commitment"].toString()).to.eq("2");
      expect(comData2["communityExtension"]).to.eq(
        communityExtension2.address
      );
      expect(comData2["role"].toString()).to.eq("2");
      expect(comData2["commitment"].toString()).to.eq("7");
      expect(await communityExtension2.isMemberOfOriginalDAO(onboarded.address)).to.eq(false);
      expect(await communityExtension2.isMemberOfExtendedDAO(onboarded.address)).to.eq(true);
    });
    it("Should not join one community twice", async function () {
      await (
        await autID
          .connect(onboarded)
          .mint(username1, URL, 3, 2, communityExtension.address)
      ).wait();
      await expect(
        autID
          .connect(onboarded)
          .joinCommunity(3, 10, communityExtension.address)
      ).to.be.revertedWith("Already a member");
    });

  });
  describe("transfer", function () {
    before(async function () {
      [dep, notAMem, ...addrs] = await ethers.getSigners();
      deployer = dep;
      
      const Community = await ethers.getContractFactory("SWLegacyCommunity");
      community = await Community.deploy();
      await community.deployed();
      await community.addMember(deployer.address);

      const MembershipTypes = await ethers.getContractFactory(
        "MembershipTypes"
      );
      membershipTypes = await MembershipTypes.deploy();
      await membershipTypes.deployed();

      const SWLegacyMembershipChecker = await ethers.getContractFactory(
        "SWLegacyMembershipChecker"
      );

      sWLegacyMembershipChecker = await SWLegacyMembershipChecker.deploy();
      await sWLegacyMembershipChecker.deployed();

      membershipTypes.addNewMembershipExtension(
        sWLegacyMembershipChecker.address
      );
    });
    beforeEach(async function () {
      [deployer, autIDHolder1, autIDHolder2, ...addrs] =
        await ethers.getSigners();

      const AutID = await ethers.getContractFactory("AutID");
      autID = await AutID.deploy();
      await autID.deployed();

      const CommunityExtension = await ethers.getContractFactory(
        "CommunityExtension"
      );

      communityExtension = await CommunityExtension.deploy(
        deployer.address,
        autID.address,
        membershipTypes.address,
        1,
        community.address,
        1,
        URL,
        10
      );
      await communityExtension.deployed();

      await community.addMember(autIDHolder1.address);
      await (
        await autID
          .connect(autIDHolder1)
          .mint(username, URL, 3, 10, communityExtension.address)
      ).wait();
    });
    it("Should fail when transferring", async function () {
      await expect(
        autID.connect(autIDHolder1).transferFrom(autIDHolder1.address, autIDHolder2.address, 0)
      ).to.revertedWith("AutID: AutID transfer disabled");
    });
  });
});
