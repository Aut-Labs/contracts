const { expect } = require("chai");
const { ethers } = require("hardhat");

let dao;
let member1;
let member2;
let polls;
let discordBot;

const URI =
  "https://hub.textile.io/ipfs/bafkreiaks3kjggtxqaj3ixk6ce2difaxj5r6lbemx5kcqdkdtub5vwv5mi";
const URI_FIN =
  "https://hub.textile.io/thread/bafkwfcy3l745x57c7vy3z2ss6ndokatjllz5iftciq4kpr4ez2pqg3i/buckets/bafzbeiaorr5jomvdpeqnqwfbmn72kdu7vgigxvseenjgwshoij22vopice";
const metadataUrl =
  "https://hub.textile.io/thread/bafkwfcy3l745x57c7vy3z2ss6ndokatjllz5iftciq4kpr4ez2pqg3i/buckets/bafzbeiaorr5jomvdpeqnqwfbmn72kdu7vgigxvseenjgwshoij22vopice";

const timestamp = Math.floor(Date.now() / 1000) + 100000;
const earlyTimestamp = Math.floor(Date.now() / 1000) - 100000;

describe("Polls", (accounts) => {
  before(async function () {
    [deployer, disBot, mem1, mem2, notAMember, ...addrs] =
      await ethers.getSigners();

    member1 = mem1;
    member2 = mem2;
    const DAO = await ethers.getContractFactory("SWLegacyCommunity");
    dao = await DAO.deploy();
    await dao.deployed();
    await dao.addMember(deployer.address);

    const DAOTypes = await ethers.getContractFactory("DAOTypes");
    daoTypes = await DAOTypes.deploy();
    await daoTypes.deployed();

    const SWLegacyMembershipChecker = await ethers.getContractFactory(
      "SWLegacyMembershipChecker"
    );

    sWLegacyMembershipChecker = await SWLegacyMembershipChecker.deploy();
    await sWLegacyMembershipChecker.deployed();

    await daoTypes.addNewMembershipChecker(
      sWLegacyMembershipChecker.address
    );

    const AutID = await ethers.getContractFactory("AutID");
    autID = await AutID.deploy();
    await autID.deployed();

    const DAOExpander = await ethers.getContractFactory(
      "DAOExpander"
    );

    daoExpander = await DAOExpander.deploy(
      deployer.address,
      autID.address,
      daoTypes.address,
      1,
      dao.address,
      1,
      URI,
      10
    );
    await daoExpander.deployed();

    await dao.addMember(member1.address);
    await dao.addMember(member2.address);

    const Polls = await ethers.getContractFactory("Polls");

    discordBot = disBot;
    polls = await Polls.deploy(daoExpander.address, discordBot.address);
    await polls.deployed();
  });
  describe("Polls", async () => {
    it("Should create some polls", async () => {
      await polls.connect(member1).create(2, timestamp, URI);
      await polls.connect(member2).create(3, timestamp, URI_FIN);
      await polls.connect(member2).create(4, earlyTimestamp, URI);

      const poll1 = await polls.getById("0");
      const poll2 = await polls.getById("1");
      const poll3 = await polls.getById("2");

      expect(poll1.pollData).to.equal(URI);
      expect(poll1.results).to.eq("");
      expect(poll1.isFinalized).to.be.false;
      expect(poll1.role).to.equal(2);
      expect(poll1.dueDate).to.equal(timestamp);

      expect(poll2.pollData).to.equal(URI_FIN);
      expect(poll2.results).to.equal("");
      expect(poll2.isFinalized).to.be.false;
      expect(poll2.role).to.equal(3);
      expect(poll2.dueDate).to.equal(timestamp);

      expect(poll3.role).to.equal(4);
    });
    it("Shouldn't be able to close unless discord bot", async () => {
      await expect(
        polls.connect(member1).close(0, URI, [member1.address])
      ).to.be.revertedWith("Only discord bot!");
    });
    it("Should not allow the close if dueDate is still not reached", async () => {
      await expect(
        polls.connect(discordBot).close(0, URI, [member1.address])
      ).to.be.revertedWith("Due date not reached yet.");
    });

    it("Should allow to close a task wiht empty reasons file", async () => {
      await expect(
        polls.connect(discordBot).close(2, "", [member1.address])
      ).to.be.revertedWith("Results file empty");
    });
    it.skip("Should close a poll", async () => {
      await polls.connect(discordBot).close(2, "", [member1.address]);
    });
  });
});
