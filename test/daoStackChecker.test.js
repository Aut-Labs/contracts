const { expect } = require("chai");
const { ethers } = require("hardhat");

let nativeToken;
let nativeReputation;
let daoStack;
let daoStackMemChecker;

let deployer;
let notDeployer;

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
