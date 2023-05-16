const { expect } = require("chai");
const { ethers } = require("hardhat");

let pluginRegistry;
let deployer, admin, verifier;
let addr1, addr2, addr3, addrs;
let offchainVerifiedTaskPlugin;
let dao;

describe("PluginRegistry", (accounts) => {
    before(async function () {
        [deployer, admin, verifier, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
        const AutID = await ethers.getContractFactory("AutID");

        autID = await upgrades.deployProxy(AutID, [admin.address], {
            from: admin,
        });
        await autID.deployed();

        const ModuleRegistryFactory = await ethers.getContractFactory("ModuleRegistry");
        const moduleRegistry = await ModuleRegistryFactory.deploy();

        const PluginRegistryFactory = await ethers.getContractFactory("PluginRegistry");
        pluginRegistry = await PluginRegistryFactory.deploy(moduleRegistry.address);

        const AutDAO = await ethers.getContractFactory("AutDAO");
        dao = await AutDAO.deploy(
            admin.address,
            autID.address,
            1,
            "someurl",
            10,
            pluginRegistry.address
        );
    });

    describe("Plugin Registry", async () => {
        it("Adds a standalone plugin type definition", async () => {
            let tx = pluginRegistry.addPluginDefinition(addr1.address, "ipfs://abcdef123456789", ethers.utils.parseEther("0.3"), true, []);
            await expect(tx).to.emit(pluginRegistry, "PluginDefinitionAdded").withArgs(1);
        });

        it("Adds a standalone & free plugin type definition", async () => {
            let tx = pluginRegistry.addPluginDefinition(addr1.address, "ipfs://abcdef123456789", ethers.utils.parseEther("0"), true, []);
            await expect(tx).to.emit(pluginRegistry, "PluginDefinitionAdded").withArgs(2);
        });

        it("Adds a not standalone & free plugin type definition", async () => {
            let tx = pluginRegistry.addPluginDefinition(addr1.address, "ipfs://abcdef123456789", ethers.utils.parseEther("0"), false, []);
            await expect(tx).to.emit(pluginRegistry, "PluginDefinitionAdded").withArgs(3);
        });
        it("Adds a standalone plugin type definition with dependencies", async () => {
            let tx = pluginRegistry.addPluginDefinition(addr1.address, "ipfs://abcdef123456789", ethers.utils.parseEther("0.1"), true, [1, 2]);
            await expect(tx).to.emit(pluginRegistry, "PluginDefinitionAdded").withArgs(4);
        });
        it("Fails if can't be standalone but paid", async () => {
            await expect(pluginRegistry.addPluginDefinition(addr1.address, "ipfs://abcdef123456789", ethers.utils.parseEther("1"), false, [])).to.be.revertedWith("AUT: Should be free if not standalone");
        });

        it("Checks the plugin definition", async () => {
            let pluginTypeDefinition = await pluginRegistry.pluginDefinitionsById(1);
            const dependencies = await pluginRegistry.getDependencyModulesForPlugin(1)
            expect(pluginTypeDefinition.creator).to.equal(addr1.address);
            expect(pluginTypeDefinition.metadataURI).to.equal("ipfs://abcdef123456789");
            expect(pluginTypeDefinition.price).to.equal(ethers.utils.parseEther("0.3"));
            expect(pluginTypeDefinition.active).to.equal(true);
            expect(pluginTypeDefinition.canBeStandalone).to.equal(true);
            expect(dependencies.length).to.equal(0);
        });
        it("Checks the plugin definition", async () => {
            let pluginTypeDefinition = await pluginRegistry.pluginDefinitionsById(4);
            const dependencies = await pluginRegistry.getDependencyModulesForPlugin(4)
            expect(pluginTypeDefinition.creator).to.equal(addr1.address);
            expect(pluginTypeDefinition.metadataURI).to.equal("ipfs://abcdef123456789");
            expect(pluginTypeDefinition.price).to.equal(ethers.utils.parseEther("0.1"));
            expect(pluginTypeDefinition.active).to.equal(true);
            expect(pluginTypeDefinition.canBeStandalone).to.equal(true);
            expect(dependencies.length).to.equal(2);
            expect(dependencies[0]).to.equal(1);
            expect(dependencies[1]).to.equal(2);
        });

        it("Changes price", async () => {
            await pluginRegistry.connect(addr1).setPrice(1, ethers.utils.parseEther("0.2"));
        });

        it("Checks price", async () => {
            let pluginTypeDefinition = await pluginRegistry.pluginDefinitionsById(1);
            expect(pluginTypeDefinition.price).to.equal(ethers.utils.parseEther("0.2"));
        });

        it("Fails to change price from wrong account", async () => {
            await expect(pluginRegistry.connect(addr2).setPrice(1, ethers.utils.parseEther("0.2"))).to.be.revertedWith("Only creator can set price");
        });
        it("Should deploy a standalone plugin", async () => {
            const OffchainVerifiedTaskPlugin = await ethers.getContractFactory(
                "OffchainVerifiedTaskPlugin"
            );
            offchainVerifiedTaskPlugin = await OffchainVerifiedTaskPlugin.deploy(
                dao.address,
                verifier.address
            );

            expect(offchainVerifiedTaskPlugin.address).not.to.be.undefined;
            expect(offchainVerifiedTaskPlugin.address).not.to.eq(ethers.constants.AddressZero);
        });

        it("Should add a free plugin to the DAO", async () => {
            let tx = pluginRegistry.connect(admin).addPluginToDAO(
                offchainVerifiedTaskPlugin.address,
                2
            );
            await expect(tx).to.emit(pluginRegistry, "PluginAddedToDAO").withArgs(1, 2, dao.address);
        });

        it("Should fail if payment is incorrect", async () => {

            await expect(pluginRegistry.connect(admin).addPluginToDAO(
                offchainVerifiedTaskPlugin.address,
                1,
                {
                    value: ethers.utils.parseEther("0.15")
                }
            )).to.be.revertedWith("Insufficient price paid");

        });

        it("Should add a paid plugin to the DAO", async () => {

            let tx = pluginRegistry.connect(admin).addPluginToDAO(
                offchainVerifiedTaskPlugin.address,
                1,
                {
                    value: ethers.utils.parseEther("0.2")
                }
            );
            await expect(tx).to.emit(pluginRegistry, "PluginAddedToDAO").withArgs(2, 1, dao.address);

        });
    });
});