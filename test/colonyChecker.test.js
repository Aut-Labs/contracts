const { expect } = require("chai");
const { ethers } = require("hardhat");

let colony;
let colonyToken;
let colonyMemChecker;

describe("ColonyMembershipChecker", function () {
    describe("isMember", function () {
        beforeEach(async function () {
            [dep, notDep, member1, member2, member3, notAMember, ...addrs] =
                await ethers.getSigners();

            const Colony = await ethers.getContractFactory("Colony");
            const ColonyToken = await ethers.getContractFactory("ColonyToken");

            colonyToken = await ColonyToken.deploy();
            await colonyToken.deployed();

            colony = await Colony.deploy(colonyToken.address);
            await colony.deployed();

            await colonyToken.increaseReputation(member1.address);
            await colonyToken.increaseReputation(member2.address);
            await colonyToken.increaseReputation(member3.address);

            const ColonyMembershipChecker = await ethers.getContractFactory(
                "ColonyMembershipChecker"
            );
            colonyMemChecker = await ColonyMembershipChecker.deploy();
            await colonyMemChecker.deployed();
        });
        it("Should return true if member", async function () {
            expect(await colonyMemChecker.isMember(colony.address, member1.address)).to.be.true;
            expect(await colonyMemChecker.isMember(colony.address, member2.address)).to.be.true;
            expect(await colonyMemChecker.isMember(colony.address, member3.address)).to.be.true;
        });
        it("Should return false if not a member", async function () {
            const isMem = await colonyMemChecker.isMember(colony.address, notAMember.address);
            expect(isMem).to.be.false;
        });
    });
});
