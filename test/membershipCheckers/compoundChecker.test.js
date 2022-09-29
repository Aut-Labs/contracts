const { expect } = require("chai");
const { ethers } = require("hardhat");

let compound;
let compoundMemChecker;

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
