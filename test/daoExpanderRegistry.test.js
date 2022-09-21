const { expect } = require("chai");
const { ethers } = require("hardhat");
const URL = "https://someurl.com";
let dao;
let daoTypes;
let sWLegacyMembershipChecker;
let autID;
let daoExpanderRegistry;
let daoExpanderFactory;
let deployer;
let notAMember;

describe("DAOExpanderRegistry", function () {
  describe("deployDAOExpander", function () {
    before(async function () {

      [dep, notAMem, ...addrs] =
        await ethers.getSigners();
      
      deployer = dep;
      notAMember = notAMem;

      const AutID = await ethers.getContractFactory("AutID");
      autID = await AutID.deploy();
      await autID.deployed();

      const DAO = await ethers.getContractFactory("SWLegacyDAO");
      dao = await DAO.deploy();
      await dao.deployed();
      await dao.addMember(deployer.address);

      await dao.addMember(deployer.address);

      const DAOTypes = await ethers.getContractFactory(
        "DAOTypes"
      );
      daoTypes = await DAOTypes.deploy();
      await daoTypes.deployed();

      const SWLegacyMembershipChecker = await ethers.getContractFactory(
        "SWLegacyMembershipChecker"
      );

      sWLegacyMembershipChecker = await SWLegacyMembershipChecker.deploy();
      await sWLegacyMembershipChecker.deployed();

      daoTypes.addNewMembershipChecker(
        sWLegacyMembershipChecker.address
      );

      const DAOExpanderFactory =  await ethers.getContractFactory(
        "DAOExpanderFactory"
      );
      daoExpanderFactory = await DAOExpanderFactory.deploy();
      await daoExpanderFactory.deployed();

      const DAOExpanderRegistry = await ethers.getContractFactory(
        "DAOExpanderRegistry"
      );

      daoExpanderRegistry = await DAOExpanderRegistry.deploy(
        // TODO: change
        autID.address,
        autID.address,
        daoTypes.address,
        daoExpanderFactory.address
      );
      await daoExpanderRegistry.deployed();
    });

    it("Should fail if arguemnts are incorret", async function () {
      await expect(
        daoExpanderRegistry.deployDAOExpander(7, dao.address, 1, URL, 8)
      ).to.be.revertedWith("DAO Type incorrect");

      await expect(
        daoExpanderRegistry.deployDAOExpander(
          1,
          ethers.constants.AddressZero,
          1,
          URL,
          8
        )
      ).to.be.revertedWith("Missing DAO Address");

      await expect(
        daoExpanderRegistry.deployDAOExpander(1, dao.address, 9, URL, 8)
      ).to.be.revertedWith("Invalid market");

      await expect(
        daoExpanderRegistry.deployDAOExpander(1, dao.address, 1, "", 8)
      ).to.be.revertedWith("Metadata URL empty");

      await expect(
        daoExpanderRegistry.deployDAOExpander(1, dao.address, 1, URL, 12)
      ).to.be.revertedWith("Invalid commitment");
    });

    it("Should fail if the signer is not a member of the original DAO", async function () {
      await expect(
        daoExpanderRegistry.connect(notAMember).deployDAOExpander(1, dao.address, 1, URL, 8)
      ).to.be.revertedWith("AutID: Not a member of this DAO!");
    });
    it("Should deploy a DAOExtension", async function () {
      const events = await (
        await daoExpanderRegistry.deployDAOExpander(1, dao.address, 1, URL, 8)
      ).wait();

      const daoExpanderDeployedEvent = events.events.find(
        (event) => event.event == "DAOExpanderDeployed"
      );

      const daoAddr = daoExpanderDeployedEvent.args['newDAOExpander'];
      expect(daoExpanderDeployedEvent).not.to.be.undefined;
      expect(daoAddr).not.to.be.undefined;
      expect(daoAddr).not.to.equal(ethers.constants.AddressZero);
      
      const daos = await daoExpanderRegistry.getDAOExpanders();
      expect(daos.length).to.eq(1);
      expect(daos[0]).to.eq(daoAddr);
    });
  });
});
