const { expect } = require("chai");
const { ethers } = require("hardhat");

let swLegacy;
let membershipTypes;
let swLegacyMemChecker;

let deployer;
let notDeployer;

describe("SWLegacyMembershipChecker", function () {
  describe("isMember", function () {
    beforeEach(async function () {
      [dep, notDep, member1, member2, member3, notAMember, ...addrs] =
        await ethers.getSigners();

      deployer = deployer;
      notDeployer = notDep;

      const SWLegacyCommunity = await ethers.getContractFactory("SWLegacyCommunity");

      swLegacy = await SWLegacyCommunity.deploy();
      await swLegacy.deployed();

      await swLegacy.addMember(member1.address);
      await swLegacy.addMember(member2.address);
      await swLegacy.addMember(member3.address);

      // SW Legacy Community Checker
      const SWLegacyMembershipChecker = await ethers.getContractFactory(
        "SWLegacyMembershipChecker"
      );
      swLegacyMemChecker = await SWLegacyMembershipChecker.deploy();
      await swLegacyMemChecker.deployed();
    });
    it("Should return true if member", async function () {
      expect(await swLegacyMemChecker.isMember(swLegacy.address, member1.address)).to.be.true;
      expect(await swLegacyMemChecker.isMember(swLegacy.address, member2.address)).to.be.true;
      expect(await swLegacyMemChecker.isMember(swLegacy.address, member3.address)).to.be.true;
    });
    it("Should return false if not a member", async function () {
      const isMem = await swLegacyMemChecker.isMember(swLegacy.address, notAMember.address);
      expect(isMem).to.be.false;
    });
  });
});
