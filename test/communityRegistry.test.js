const { expect } = require("chai");
const { ethers } = require("hardhat");
const URL = "https://someurl.com";
let communityExtension;
let community;
let membershipTypes;
let sWLegacyMembershipChecker;
let autID;
let communityRegistry;
let deployer;
let notAMember;

describe("CommunityRegistry", function () {
  describe("createCommunity", function () {
    before(async function () {

      [dep, notAMem, ...addrs] =
        await ethers.getSigners();
      
      deployer = dep;
      notAMember = notAMem;

      const AutID = await ethers.getContractFactory("AutID");
      autID = await AutID.deploy();
      await autID.deployed();

      const Community = await ethers.getContractFactory("SWLegacyCommunity");
      community = await Community.deploy();
      await community.deployed();
      await community.addMember(deployer.address);

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

      const CommunityRegistry = await ethers.getContractFactory(
        "CommunityRegistry"
      );

      communityRegistry = await CommunityRegistry.deploy(
        autID.address,
        membershipTypes.address
      );
      await communityRegistry.deployed();
    });

    it("Should fail if arguemnts are incorret", async function () {
      await expect(
        communityRegistry.createCommunity(7, community.address, 1, URL, 8)
      ).to.be.revertedWith("Membership Type incorrect");

      await expect(
        communityRegistry.createCommunity(
          1,
          ethers.constants.AddressZero,
          1,
          URL,
          8
        )
      ).to.be.revertedWith("Missing DAO Address");

      await expect(
        communityRegistry.createCommunity(1, community.address, 9, URL, 8)
      ).to.be.revertedWith("Invalid market");

      await expect(
        communityRegistry.createCommunity(1, community.address, 1, "", 8)
      ).to.be.revertedWith("Metadata URL empty");

      await expect(
        communityRegistry.createCommunity(1, community.address, 1, URL, 12)
      ).to.be.revertedWith("Invalid commitment");
    });

    it("Should fail if the signer is not a member of the original DAO", async function () {
      await expect(
        communityRegistry.connect(notAMember).createCommunity(1, community.address, 1, URL, 8)
      ).to.be.revertedWith("AutID: Not a member of this DAO!");
    });
    it("Should deploy a CommunityExtension", async function () {
      const events = await (
        await communityRegistry.createCommunity(1, community.address, 1, URL, 8)
      ).wait();

      const communityDeployedEvent = events.events.find(
        (event) => event.event == "CommunityCreated"
      );

      const comAddr = communityDeployedEvent.args['newCommunityAddress'];
      expect(communityDeployedEvent).not.to.be.undefined;
      expect(comAddr).not.to.be.undefined;
      expect(comAddr).not.to.equal(ethers.constants.AddressZero);
      
      const coms = await communityRegistry.getCommunities();
      expect(coms.length).to.eq(1);
      expect(coms[0]).to.eq(comAddr);
    });
  });
});
