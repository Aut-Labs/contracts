const { expect } = require("chai");
const { ethers } = require("hardhat");

let daoTypes;
let swLegacyMemChecker;
let molochMemChecker;

let deployer;
let notDeployer;

describe("DAOTypes", function () {
  describe("addNewMembershipChecker", function () {
    beforeEach(async function () {
      [dep, notDep, ...addrs] = await ethers.getSigners();

      deployer = deployer;
      notDeployer = notDep;
      const DAOTypes = await ethers.getContractFactory(
        "DAOTypes"
      );
      daoTypes = await DAOTypes.deploy();
      await daoTypes.deployed();

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

      // Tribute Community Checker
      const TributeMembershipChecker = await ethers.getContractFactory(
        "TributeMembershipChecker"
      );
      tributeMemChecker = await TributeMembershipChecker.deploy();
      await tributeMemChecker.deployed();
    });
    it("Should fail if arguemnts are incorret", async function () {
        await expect(
        daoTypes.addNewMembershipChecker(ethers.constants.AddressZero)
      ).to.revertedWith("MembershipChecker contract address must be provided");
    });
    it("Should fail if the caller is not the owner", async function () {
      await expect(
        daoTypes
          .connect(notDeployer)
          .addNewMembershipChecker(ethers.constants.AddressZero)
      ).to.revertedWith("Ownable: caller is not the owner");
    });
    it("Should fail if the membership checker is already added", async function () {
      await daoTypes.addNewMembershipChecker(
        swLegacyMemChecker.address
      );
      await expect(
        daoTypes.addNewMembershipChecker(swLegacyMemChecker.address)
      ).to.revertedWith("MembershipChecker already added");
    });
    it("Should add a new membership type", async function () {
      await (
        await daoTypes.addNewMembershipChecker(
          molochMemChecker.address
        )
      ).wait();
      const typesCountBefore = await daoTypes.typesCount();
      const events = await (
        await daoTypes.addNewMembershipChecker(
          swLegacyMemChecker.address
        )
      ).wait();

      const typesCountAfter = await daoTypes.typesCount();
      const event = events.events.find((e) => e.event == "DAOTypeAdded");

      expect(event.args.daoType.toString()).to.eq("2");
      expect(event.args.membershipCheckerAddress).to.eq(
        swLegacyMemChecker.address
      );

      const addedMemType = await daoTypes.getMembershipCheckerAddress(
        event.args.daoType.toString()
      );

      expect(addedMemType).to.eq(swLegacyMemChecker.address);
      expect(+typesCountBefore.toString() + 1).to.eq(
        +typesCountAfter.toString()
      );
    });
  });
});
