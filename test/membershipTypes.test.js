const { expect } = require("chai");
const { ethers } = require("hardhat");

let membershipTypes;
let swLegacyMemChecker;
let molochMemChecker;

let deployer;
let notDeployer;

describe("MembershipTypes", function () {
  describe("addNewMembershipExtension", function () {
    beforeEach(async function () {
      [dep, notDep, ...addrs] = await ethers.getSigners();

      deployer = deployer;
      notDeployer = notDep;
      const MembershipTypes = await ethers.getContractFactory(
        "MembershipTypes"
      );
      membershipTypes = await MembershipTypes.deploy();
      await membershipTypes.deployed();

      // SW Legacy Community Checker
      const SWLegacyMembershipChecker = await ethers.getContractFactory(
        "SWLegacyMembershipChecker"
      );
      swLegacyMemChecker = await SWLegacyMembershipChecker.deploy();
      await swLegacyMemChecker.deployed();

      // Moloch Community Checker
      const MolochV2MembershipChecker = await ethers.getContractFactory(
        "MolochV2MembershipChecker"
      );
      molochMemChecker = await MolochV2MembershipChecker.deploy();
      await molochMemChecker.deployed();
    });
    it("Should fail if arguemnts are incorret", async function () {
        await expect(
        membershipTypes.addNewMembershipExtension(ethers.constants.AddressZero)
      ).to.revertedWith("MembershipChecker contract address must be provided");
    });
    it("Should fail if the caller is not the owner", async function () {
      await expect(
        membershipTypes
          .connect(notDeployer)
          .addNewMembershipExtension(ethers.constants.AddressZero)
      ).to.revertedWith("Ownable: caller is not the owner");
    });
    it("Should fail if the membership checker is already added", async function () {
      await membershipTypes.addNewMembershipExtension(
        swLegacyMemChecker.address
      );
      await expect(
        membershipTypes.addNewMembershipExtension(swLegacyMemChecker.address)
      ).to.revertedWith("MembershipChecker already added");
    });
    it("Should add a new membership type", async function () {
      await (
        await membershipTypes.addNewMembershipExtension(
          molochMemChecker.address
        )
      ).wait();
      const typesCountBefore = await membershipTypes.typesCount();
      const events = await (
        await membershipTypes.addNewMembershipExtension(
          swLegacyMemChecker.address
        )
      ).wait();

      const typesCountAfter = await membershipTypes.typesCount();
      const event = events.events.find((e) => e.event == "MembershipTypeAdded");

      expect(event.args.memType.toString()).to.eq("2");
      expect(event.args.membershipExtContract).to.eq(
        swLegacyMemChecker.address
      );

      const addedMemType = await membershipTypes.getMembershipExtensionAddress(
        event.args.memType.toString()
      );

      expect(addedMemType).to.eq(swLegacyMemChecker.address);
      expect(+typesCountBefore.toString() + 1).to.eq(
        +typesCountAfter.toString()
      );
    });
  });
});
