const { expect } = require("chai");
const { ethers } = require("hardhat");

let dao;
let member1;
let member2;
let tasks;

const URI =
  "https://hub.textile.io/ipfs/bafkreiaks3kjggtxqaj3ixk6ce2difaxj5r6lbemx5kcqdkdtub5vwv5mi";
const URI_FIN =
  "https://hub.textile.io/thread/bafkwfcy3l745x57c7vy3z2ss6ndokatjllz5iftciq4kpr4ez2pqg3i/buckets/bafzbeiaorr5jomvdpeqnqwfbmn72kdu7vgigxvseenjgwshoij22vopice";

describe("Tasks", (accounts) => {
  before(async function () {
    [deployer, mem1, mem2, notAMember, ...addrs] = await ethers.getSigners();

    member1 = mem1;
    member2 = mem2;
    const Community = await ethers.getContractFactory("SWLegacyDAO");
    dao = await Community.deploy();
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

    const Tasks = await ethers.getContractFactory("Tasks");

    tasks = await Tasks.deploy(daoExpander.address);
    await tasks.deployed();

    await daoExpander.addActivitiesAddress(tasks.address, '3');
  });
  describe("Tasks", async () => {
    it("Should create some tasks", async () => {
      await tasks.connect(member1).create(4, URI);
      await tasks.connect(member2).create(4, URI_FIN);
      await tasks.connect(member1).create(3, URI);

      const task1 = await tasks.getById("0");
      const task2 = await tasks.getById("1");

      expect(task1.status).to.equal(0);
      expect(task1.creator).to.equal(member1.address);
      expect(task1.taker).to.equal(ethers.constants.AddressZero);
      expect(task1.metadata).to.equal(URI);

      expect(task2.status).to.equal(0);
      expect(task2.creator).to.equal(member2.address);
      expect(task2.taker).to.equal(ethers.constants.AddressZero);
      expect(task2.metadata).to.equal(URI_FIN);
    });
    it("Should take the task", async () => {
      await tasks.connect(member2).take(0);

      const task1 = await tasks.getById("0");

      expect(task1.status).to.equal(1);
      expect(task1.creator).to.equal(member1.address);
      expect(task1.taker).to.equal(member2.address);
    });
    it("Should not allow to take task that is already taken", async () => {
      await expect(tasks.connect(member2).take(0)).to.be.revertedWith(
        "wrong status"
      );
    });

    it("Should submit the task", async () => {
      await tasks.connect(member2).submit(0, URI_FIN);

      const task1 = await tasks.getById(0);

      expect(task1.status).to.equal(2);
      expect(task1.creator).to.equal(member1.address);
      expect(task1.taker).to.equal(member2.address);
    });
    it("Should not allow to submit task that is already submitted", async () => {
      await expect(
        tasks.connect(member1).submit(0, URI_FIN)
      ).to.be.revertedWith("wrong status");
    });
    it("Should allow to finalize submitted task", async () => {
      await tasks.connect(member1).finalize(0);
      const task1 = await tasks.getById(0);

      expect(task1.status).to.equal(3);
      expect(task1.creator).to.equal(member1.address);
      expect(task1.taker).to.equal(member2.address);

      expect(await tasks.isFinalized(0)).to.equal(true);

      const interactionIndex = await daoExpander.getInteractionsPerUser(
        task1.taker
      );
      expect(interactionIndex.toString()).to.equal("1");
    });
    it("Should not allow to finalze task that is not submitted", async () => {
      await expect(tasks.connect(member1).finalize(0)).to.be.revertedWith(
        "wrong status"
      );
      await expect(tasks.connect(member2).finalize(1)).to.be.revertedWith(
        "wrong status"
      );
    });
    it("Should not allow the creator to take their task", async () => {
      await expect(tasks.connect(member2).take(1)).to.be.revertedWith(
        "Creator can't take the task"
      );
    });
  });
});
