const { expect } = require("chai");
const { ethers } = require("hardhat");

let moloch;
let membershipTypes;
let molochMemChecker;

let deployer;
let notDeployer;

describe("MolochV2MembershipChecker", function () {
  describe("isMember", function () {
    beforeEach(async function () {
      [dep, notDep, member1, member2, member3, notAMember, ...addrs] =
        await ethers.getSigners();

      deployer = deployer;
      notDeployer = notDep;

      const Moloch = await ethers.getContractFactory("Moloch");

      moloch = await Moloch.deploy();
      await moloch.deployed();

      await moloch.addMember(member1.address);
      await moloch.addMember(member2.address);
      await moloch.addMember(member3.address);

      // Moloch Community Checker
      const MolochV2MembershipChecker = await ethers.getContractFactory(
        "MolochV2MembershipChecker"
      );
      molochMemChecker = await MolochV2MembershipChecker.deploy();
      await molochMemChecker.deployed();
    });
    it("Should return true if member", async function () {
      expect(await molochMemChecker.isMember(moloch.address, member1.address)).to.be.true;
      expect(await molochMemChecker.isMember(moloch.address, member2.address)).to.be.true;
      expect(await molochMemChecker.isMember(moloch.address, member3.address)).to.be.true;
    });
    it("Should return false if not a member", async function () {
      const isMem = await molochMemChecker.isMember(moloch.address, notAMember.address);
      expect(isMem).to.be.false;
    });
  });
});
