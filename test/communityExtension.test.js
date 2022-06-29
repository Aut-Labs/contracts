const { expect } = require("chai");
const { ethers } = require("hardhat");
const URL = "https://someurl.com";
let communityExtension;
let community;
let membershipTypes;
let sWLegacyMembershipChecker;
let autID;
let deployer;

describe("CommunityExtension", function () {
  describe("deployment", function () {
    before(async function () {
      [dep, notAMem, ...addrs] = await ethers.getSigners();
      deployer = dep;
      
      const AutID = await ethers.getContractFactory("AutID");
      autID = await AutID.deploy();
      await autID.deployed();

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
    it("Should fail if arguemnts are incorret", async function () {
      const CommunityExtension = await ethers.getContractFactory(
        "CommunityExtension"
      );
      await expect(
        CommunityExtension.deploy(
          deployer.address,
          autID.address,
          ethers.constants.AddressZero,
          1,
          community.address,
          1,
          URL,
          10
        )
      ).to.be.revertedWith("Missing memTypes address");
      await expect(
        CommunityExtension.deploy(
          deployer.address,
          autID.address,
          membershipTypes.address,
          7,
          community.address,
          1,
          URL,
          10
        )
      ).to.be.revertedWith("Invalid membership type");
      await expect(
        CommunityExtension.deploy(
          deployer.address,
          autID.address,
          membershipTypes.address,
          1,
          ethers.constants.AddressZero,
          1,
          URL,
          10
        )
      ).to.be.revertedWith("Missing DAO Address");
      await expect(
        CommunityExtension.deploy(
          deployer.address,
          autID.address,
          membershipTypes.address,
          1,
          community.address,
          7,
          URL,
          10
        )
      ).to.be.revertedWith("Invalid market");

      await expect(
        CommunityExtension.deploy(
          deployer.address,
          autID.address,
          membershipTypes.address,
          1,
          community.address,
          2,
          "",
          10
        )
      ).to.be.revertedWith("Missing Metadata URL");

      await expect(
        CommunityExtension.deploy(
          deployer.address,
          autID.address,
          membershipTypes.address,
          1,
          community.address,
          2,
          URL,
          0
        )
      ).to.be.revertedWith("Commitment should be between 1 and 10");
      await expect(
        CommunityExtension.deploy(
          deployer.address,
          autID.address,
          membershipTypes.address,
          1,
          community.address,
          2,
          URL,
          11
        )
      ).to.be.revertedWith("Commitment should be between 1 and 10");
    });
    it("Should deploy a CommunityExtension", async function () {
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

      expect(communityExtension.address).to.not.be.null;
    });
  });
  describe("Manage URLs", async () => {
    before(async function () {
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
    });
    it("Should return false when URL list is empty", async () => {
      expect(await communityExtension.isURLListed("")).to.equal(false);
    });
    it("Should add an URL to the list", async () => {
      await communityExtension.addURL("https://test1.test");
      const urls = await communityExtension.getURLs();

      expect(
        await communityExtension.isURLListed("https://test1.test")
      ).to.equal(true);
      expect(urls.length).to.equal(1);
      expect(urls[0]).to.equal("https://test1.test");
    });
    it("Should remove an URL from the list", async () => {
      await communityExtension.removeURL("https://test1.test");
      const urls = await communityExtension.getURLs();

      expect(
        await communityExtension.isURLListed("https://test1.test")
      ).to.equal(false);
      expect(urls.length).to.equal(0);
    });
    it("Should add 3 more URLs to the list", async () => {
      await communityExtension.addURL("https://test1.test");
      await communityExtension.addURL("https://test2.test");
      await communityExtension.addURL("https://test3.test");
      const urls = await communityExtension.getURLs();

      expect(
        await communityExtension.isURLListed("https://test1.test")
      ).to.equal(true);
      expect(
        await communityExtension.isURLListed("https://test2.test")
      ).to.equal(true);
      expect(
        await communityExtension.isURLListed("https://test3.test")
      ).to.equal(true);
      expect(urls.length).to.equal(3);
      expect(urls[0]).to.equal("https://test1.test");
      expect(urls[1]).to.equal("https://test2.test");
      expect(urls[2]).to.equal("https://test3.test");
    });
    it("Should not allow adding already existing URL to the list", async () => {
      await expect(
        communityExtension.addURL("https://test2.test")
      ).to.be.revertedWith("url already exists");
    });
    it("Should return false when URL is not listed", async () => {
      expect(
        await communityExtension.isURLListed("https://test4.test")
      ).to.equal(false);
      expect(await communityExtension.isURLListed("")).to.equal(false);
    });
    it("Should not allow removing of non existing URL", async () => {
      await expect(
        communityExtension.removeURL("https://test4.test")
      ).to.be.revertedWith("url doesnt exist");
      await expect(communityExtension.removeURL("")).to.be.revertedWith(
        "url doesnt exist"
      );
    });
    it("Should remove one of the URLs from the list", async () => {
      await communityExtension.removeURL("https://test2.test");
      const urls = await communityExtension.getURLs();

      expect(
        await communityExtension.isURLListed("https://test1.test")
      ).to.equal(true);
      expect(
        await communityExtension.isURLListed("https://test2.test")
      ).to.equal(false);
      expect(
        await communityExtension.isURLListed("https://test3.test")
      ).to.equal(true);
      expect(urls.length).to.equal(2);
      expect(urls[0]).to.equal("https://test1.test");
      expect(urls[1]).to.equal("https://test3.test");
    });
    it("Should remove last URLs from the list", async () => {
      await communityExtension.removeURL("https://test3.test");
      const urls = await communityExtension.getURLs();

      expect(
        await communityExtension.isURLListed("https://test1.test")
      ).to.equal(true);
      expect(
        await communityExtension.isURLListed("https://test2.test")
      ).to.equal(false);
      expect(
        await communityExtension.isURLListed("https://test3.test")
      ).to.equal(false);
      expect(urls.length).to.equal(1);
      expect(urls[0]).to.equal("https://test1.test");
    });
    it("Should add one more URLs to the (end of) list", async () => {
      await communityExtension.addURL("https://test2.test");
      const urls = await communityExtension.getURLs();

      expect(
        await communityExtension.isURLListed("https://test1.test")
      ).to.equal(true);
      expect(
        await communityExtension.isURLListed("https://test2.test")
      ).to.equal(true);
      expect(
        await communityExtension.isURLListed("https://test3.test")
      ).to.equal(false);
      expect(urls.length).to.equal(2);
      expect(urls[0]).to.equal("https://test1.test");
      expect(urls[1]).to.equal("https://test2.test");
    });
  });
});
