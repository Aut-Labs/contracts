const { expect } = require("chai");
const { ethers } = require("hardhat");

let aragon;
let membershipTypes;
let aragonMemChecker;
let aragonVoting, aragonTokenManager;

let deployer;
let notDeployer;

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
