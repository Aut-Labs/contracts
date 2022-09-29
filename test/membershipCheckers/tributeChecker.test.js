const { expect } = require("chai");
const { ethers } = require("hardhat");

let tribute;
let membershipTypes;
let tributeMemChecker;

let deployer;
let notDeployer;

describe("TributeMembershipChecker", function () {
  describe("isMember", function () {
    beforeEach(async function () {
      [dep, notDep, member1, member2, member3, notAMember, ...addrs] =
        await ethers.getSigners();

      deployer = deployer;
      notDeployer = notDep;

      const Tribute = await ethers.getContractFactory("Tribute");

      tribute = await Tribute.deploy();
      await tribute.deployed();

      await tribute.addMember(member1.address);
      await tribute.addMember(member2.address);
      await tribute.addMember(member3.address);

      // Tribute Community Checker
      const TributeMembershipChecker = await ethers.getContractFactory(
        "TributeMembershipChecker"
      );
      tributeMemChecker = await TributeMembershipChecker.deploy();
      await tributeMemChecker.deployed();
    });
    it("Should return true if member", async function () {
      expect(await tributeMemChecker.isMember(tribute.address, member1.address)).to.be.true;
      expect(await tributeMemChecker.isMember(tribute.address, member2.address)).to.be.true;
      expect(await tributeMemChecker.isMember(tribute.address, member3.address)).to.be.true;
    });
    it("Should return false if not a member", async function () {
      const isMem = await tributeMemChecker.isMember(tribute.address, notAMember.address);
      expect(isMem).to.be.false;
    });
  });
});
