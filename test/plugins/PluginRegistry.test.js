const { expect } = require("chai");
const { ethers } = require("hardhat");

let pluginRegistry;
let deployer;
let addr1, addr2, addr3, addrs;

describe.skip("PluginRegistry", (accounts) => {
    before(async function() {
        [deployer, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
        const ModuleRegistryFactory = await ethers.getContractFactory("ModuleRegistry");
        const moduleRegistry = await ModuleRegistryFactory.deploy();
  
        const PluginRegistryFactory = await ethers.getContractFactory("PluginRegistry");
        pluginRegistry = await PluginRegistryFactory.deploy(moduleRegistry.address);
    });

    describe("Plugin Registry", async() => {
        it("Adds a plugin type definition", async() => {
            let tx = pluginRegistry.addPluginDefinition(addr1.address, "ipfs://abcdef123456789", ethers.utils.parseEther("0.1"));
            await expect(tx).to.emit(pluginRegistry, "PluginDefinitionAdded").withArgs(1);
        });

        it("Adds a free plugin type definition", async() => {
            let tx = pluginRegistry.addPluginDefinition(addr1.address, "ipfs://abcdef123456789", ethers.utils.parseEther("0"));
            await expect(tx).to.emit(pluginRegistry, "PluginDefinitionAdded").withArgs(2);
        });

        it("Checks the plugin type", async() => {
            let pluginTypeDefinition = await pluginRegistry.pluginTypesById(1);
            expect(pluginTypeDefinition.creator).to.equal(addr1.address);
            expect(pluginTypeDefinition.metadataURI).to.equal("ipfs://abcdef123456789");
            expect(pluginTypeDefinition.price).to.equal(ethers.utils.parseEther("0.1"));
            expect(pluginTypeDefinition.active).to.equal(true);
        });

        it("Changes price", async() => {
            await pluginRegistry.connect(addr1).setPrice(1, ethers.utils.parseEther("0.2"));
        });

        it("Fails to change price from wrong account", async() => {
            await expect(pluginRegistry.connect(addr2).setPrice(1, ethers.utils.parseEther("0.2"))).to.be.revertedWith("Only creator can set price");
        });

        it("Buys a plugin", async() => {
            const daoExpanderAddress = addr3.address;

            let tx = pluginRegistry.connect(addr2).addPluginToDAO(
                daoExpanderAddress, // DAO address
                {
                    value: ethers.utils.parseEther("0.2")
                }
            );

            await expect(tx).to.emit(pluginRegistry, "PluginAddedToDAO").withArgs(1, 1, daoExpanderAddress);

            // check owner of token 1
            let owner = await pluginRegistry.ownerOf(1);
            expect(owner).to.equal(addr2.address);
        });


        it("Gets a free plugin", async() => {
            const daoExpanderAddress = addr3.address;

            let tx = pluginRegistry.connect(addr2).addPluginToDAO(
                2, // Plugin ID
                daoExpanderAddress, // DAO address
            );

            await expect(tx).to.emit(pluginRegistry, "PluginAddedToDAO").withArgs(2, 2, daoExpanderAddress);

            // check owner of token 1
            let owner = await pluginRegistry.ownerOf(1);
            expect(owner).to.equal(addr2.address);
        });

        it("Reverts when buying a plugin paying wrong amount", async() => {
            const daoExpanderAddress = addr3.address;

            await expect(pluginRegistry.connect(addr2).addPluginToDAO(
                1, // Plugin ID
                daoExpanderAddress, // DAO address
                {
                    value: ethers.utils.parseEther("0.1")
                }
            )).to.be.revertedWith("Insufficient price paid");
        });
    });
});