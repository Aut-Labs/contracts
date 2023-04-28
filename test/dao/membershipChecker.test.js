const { expect } = require("chai");
const { ethers } = require("hardhat");

let aragonMemChecker;
let aragonVoting, aragonTokenManager;

let deployer;
describe("MembershipCheckers", function () {
  describe("AragonMembershipChecker", function () {
    describe("isMember", function () {
      beforeEach(async function () {
        [dep, notDep, member1, member2, member3, notAMember, ...addrs] =
          await ethers.getSigners();

        deployer = deployer;
        notDeployer = notDep;

        const AragonToken = await ethers.getContractFactory('TestERC20');
        aragonToken = await AragonToken.deploy('Fancy Voting Token', 'FVT', member1.address, '1500');
        await aragonToken.deployed();

        const AragonTokenManager = await ethers.getContractFactory("AragonTokenManagerApp");
        aragonTokenManager = await AragonTokenManager.deploy(aragonToken.address);
        await aragonTokenManager.deployed();

        const AragonVoting = await ethers.getContractFactory("AragonVotingApp");
        aragonVoting = await AragonVoting.deploy(aragonToken.address);
        await aragonVoting.deployed();

        await aragonToken.transferInternal(member1.address, member2.address, 700);
        await aragonToken.transferInternal(member1.address, member3.address, 700);

        // Aragon Community Checker
        const AragonMembershipChecker = await ethers.getContractFactory(
          "AragonMembershipChecker"
        );
        aragonMemChecker = await AragonMembershipChecker.deploy();

        await aragonMemChecker.deployed();
      });

      it("Should return true if member", async function () {
        expect(await aragonMemChecker.isMember(aragonTokenManager.address, member1.address)).to.be.true;
        expect(await aragonMemChecker.isMember(aragonVoting.address, member2.address)).to.be.true;
        expect(await aragonMemChecker.isMember(aragonTokenManager.address, member3.address)).to.be.true;
      });
      it("Should return false if not a member", async function () {
        expect(await aragonMemChecker.isMember(aragonTokenManager.address, notAMember.address)).to.be.false;
        expect(await aragonMemChecker.isMember(aragonVoting.address, notAMember.address)).to.be.false;
      });
    });
  });
  describe("CompoundMembershipChecker", function () {
    describe("isMember", function () {
      beforeEach(async function () {
        [dep, notDep, member1, member2, member3, notAMember, ...addrs] =
          await ethers.getSigners();

        const Compound = await ethers.getContractFactory("Compound");

        compound = await Compound.deploy();
        await compound.deployed();

        await compound.addMember(member1.address);
        await compound.addMember(member2.address);
        await compound.addMember(member3.address);

        const CompoundMembershipChecker = await ethers.getContractFactory(
          "CompoundMembershipChecker"
        );
        compoundMemChecker = await CompoundMembershipChecker.deploy();
        await compoundMemChecker.deployed();
      });
      // noinspection DuplicatedCode
      it("Should return true if member", async function () {
        expect(await compoundMemChecker.isMember(compound.address, member1.address)).to.be.true;
        expect(await compoundMemChecker.isMember(compound.address, member2.address)).to.be.true;
        expect(await compoundMemChecker.isMember(compound.address, member3.address)).to.be.true;
      });
      it("Should return false if not a member", async function () {
        const isMem = await compoundMemChecker.isMember(compound.address, notAMember.address);
        expect(isMem).to.be.false;
      });
    });
  });
  describe("DAOStackMembershipChecker", function () {
    describe("isMember", function () {
      beforeEach(async function () {
        [dep, notDep, member1, member2, member3, notAMember, ...addrs] =
          await ethers.getSigners();

        deployer = dep;
        notDeployer = notDep;

        const NativeToken = await ethers.getContractFactory("TestERC20");
        const NativeReputation = await ethers.getContractFactory("TestERC20");
        const DAOStack = await ethers.getContractFactory("DAOStack");

        nativeToken = await NativeToken.deploy("token", "token", deployer.address, 10);
        await nativeToken.deployed();
        await nativeToken.transferInternal(deployer.address, member1.address, 1);
        await nativeToken.transferInternal(deployer.address, member3.address, 1);

        nativeReputation = await NativeReputation.deploy("reputation", "reputation", deployer.address, 10);
        await nativeReputation.deployed();
        await nativeReputation.transferInternal(deployer.address, member2.address, 1)
        await nativeReputation.transferInternal(deployer.address, member3.address, 1);

        daoStack = await DAOStack.deploy(nativeToken.address, nativeReputation.address);
        await daoStack.deployed();

        // Moloch Community Checker
        const DAOStackMembershipChecker = await ethers.getContractFactory(
          "DAOStackMembershipChecker"
        );
        daoStackMemChecker = await DAOStackMembershipChecker.deploy();
        await daoStackMemChecker.deployed();
      });
      it("Should return true if member", async function () {
        expect(await daoStackMemChecker.isMember(daoStack.address, member1.address)).to.be.true;
        expect(await daoStackMemChecker.isMember(daoStack.address, member2.address)).to.be.true;
        expect(await daoStackMemChecker.isMember(daoStack.address, member3.address)).to.be.true;
      });
      it("Should return false if not a member", async function () {
        const isMem = await daoStackMemChecker.isMember(daoStack.address, notAMember.address);
        expect(isMem).to.be.false;
      });
    });
  });
  describe("MolochV2MembershipChecker", function () {
    describe("isMember", function () {
      beforeEach(async function () {
        [dep, notDep, member1, member2, member3, notAMember, ...addrs] =
          await ethers.getSigners();

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
  describe("SWLegacyMembershipChecker", function () {
    describe("isMember", function () {
      beforeEach(async function () {
        [dep, notDep, member1, member2, member3, notAMember, ...addrs] =
          await ethers.getSigners();

        deployer = deployer;
        notDeployer = notDep;

        const SWLegacyDAO = await ethers.getContractFactory("SWLegacyDAO");

        swLegacy = await SWLegacyDAO.deploy();
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
});
