const { expect } = require("chai");
const { ethers } = require("hardhat");
const { soliditySha3 } = require("web3-utils");

let colony;
let colonyNetwork;
let colonyWhitelist;
let colonyMemChecker;

const WHITELIST = soliditySha3("Whitelist");

describe("ColonyMembershipChecker", function () {
    describe("isMember", function () {
        beforeEach(async function () {
            [dep, notDep, member1, member2, member3, notAMember, ...addrs] =
                await ethers.getSigners();

            const ColonyNetwork = await ethers.getContractFactory("ColonyNetwork");
            const Colony = await ethers.getContractFactory("Colony");
            const ColonyWhitelist = await ethers.getContractFactory("ColonyWhitelist");

            colonyNetwork = await ColonyNetwork.deploy();

            colony = await Colony.deploy(colonyNetwork.address);
            await colony.deployed();

            colonyWhitelist = await ColonyWhitelist.deploy();
            await colonyWhitelist.deployed();

            await colonyNetwork.setExtension(WHITELIST, colonyWhitelist.address, colony.address);

            await colonyWhitelist.addMember(member1.address);
            await colonyWhitelist.addMember(member2.address);
            await colonyWhitelist.addMember(member3.address);

            const ColonyMembershipChecker = await ethers.getContractFactory(
                "ColonyMembershipChecker"
            );
            colonyMemChecker = await ColonyMembershipChecker.deploy();
            await colonyMemChecker.deployed();
        });
        it("Should return true if member", async function () { // noinspection DuplicatedCode
            expect(await colonyMemChecker.isMember(colony.address, dep.address)).to.be.true;
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
