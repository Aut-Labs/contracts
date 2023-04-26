const { expect } = require("chai");
const { ethers } = require("hardhat");

let moduleRegistry;
let deployer;
let addr1, addr2, addr3, addrs;
let url = 'http://some.url';

describe("ModulesRegistry", (accounts) => {
    before(async function () {
        [deployer, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();

    });

    describe("Modules Registry", async () => {
        it("Should deploy ModulesRegistry", async () => {
            const ModuleRegistryFactory = await ethers.getContractFactory("ModuleRegistry");
            moduleRegistry = await ModuleRegistryFactory.deploy();
            expect(moduleRegistry.address).not.eq(ethers.constants.AddressZero);
            expect(moduleRegistry.address).not.to.be.undefined;
        });

        it("Owner should be deployer", async () => {
            let owner = await moduleRegistry.owner();
            expect(owner).to.eq(deployer.address);
        });

        it("Should have 3 mondules after deployment", async () => {
            let modules = await moduleRegistry.getAllModules();
            expect(modules.length).to.eq(4);

            expect(modules[0]['metadataURI']).to.eq('none');
            expect(modules[0]['name']).to.eq('NONE');
            expect(modules[1]['metadataURI']).to.eq('onboarding uri');
            expect(modules[1]['name']).to.eq('Onboarding');
            expect(modules[2]['metadataURI']).to.eq('task uri');
            expect(modules[2]['name']).to.eq('Task');
            expect(modules[3]['metadataURI']).to.eq('quest uri');
            expect(modules[3]['name']).to.eq('Quest');

            let singleModule1 = await moduleRegistry.getModuleById(1);
            expect(singleModule1['metadataURI']).to.eq('onboarding uri');
            expect(singleModule1['name']).to.eq('Onboarding');

            let singleModule3 = await moduleRegistry.getModuleById(3);
            expect(singleModule3['metadataURI']).to.eq('quest uri');
            expect(singleModule3['name']).to.eq('Quest');

        });
        it("Add module def should fail if not owner", async () => {
            await expect(moduleRegistry.connect(addr1).addModuleDefinition(url, 'governance')).to.be.revertedWith("Ownable: caller is not the owner");
        });

        it("Add module def should fail with invalid arguments", async () => {
            await expect(moduleRegistry.connect(deployer).addModuleDefinition("", 'governance')).to.be.revertedWith("invalid uri");
            await expect(moduleRegistry.connect(deployer).addModuleDefinition(url, "")).to.be.revertedWith("invalid name");
        });

        it("Add module def should pass", async () => {
            const tx = await moduleRegistry.connect(deployer).addModuleDefinition(url, 'governance');
            await expect(tx).to.emit(moduleRegistry, "ModuleDefinitionAdded").withArgs(4);

            let singleModule = await moduleRegistry.getModuleById(4);
            expect(singleModule['metadataURI']).to.eq(url);
            expect(singleModule['name']).to.eq('governance');

            let modules = await moduleRegistry.getAllModules();
            expect(modules.length).to.eq(5);

            expect(modules[4]['metadataURI']).to.eq(url);
            expect(modules[4]['name']).to.eq('governance');
        });
    });
});