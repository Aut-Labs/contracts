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
            expect(modules[0]['id'].toString()).to.eq('0');
            expect(modules[1]['metadataURI']).to.eq('ipfs://bafkreiajwhzd36nkt44bqgtyh7upkgoiooxqzafp62qh4zagkfihcssgpu');
            expect(modules[1]['id'].toString()).to.eq('1');
            expect(modules[2]['metadataURI']).to.eq('ipfs://bafkreihxcz6eytmf6lm5oyqee67jujxepuczl42lw2orlfsw6yds5gm46i');
            expect(modules[2]['id'].toString()).to.eq('2');
            expect(modules[3]['metadataURI']).to.eq('ipfs://bafkreieg7dwphs4554g726kalv5ez22hd55k3bksepa6rrvon6gf4mupey');
            expect(modules[3]['id'].toString()).to.eq('3');

            let singleModule1 = await moduleRegistry.getModuleById(1);
            expect(singleModule1['metadataURI']).to.eq('ipfs://bafkreiajwhzd36nkt44bqgtyh7upkgoiooxqzafp62qh4zagkfihcssgpu');
            expect(singleModule1['id'].toString()).to.eq('1');

            let singleModule3 = await moduleRegistry.getModuleById(3);
            expect(singleModule3['metadataURI']).to.eq('ipfs://bafkreieg7dwphs4554g726kalv5ez22hd55k3bksepa6rrvon6gf4mupey');
            expect(singleModule3['id'].toString()).to.eq('3');

        });
        it("Add module def should fail if not owner", async () => {
            await expect(moduleRegistry.connect(addr1).addModuleDefinition(url)).to.be.revertedWith("Ownable: caller is not the owner");
        });

        it("Add module def should fail with invalid arguments", async () => {
            await expect(moduleRegistry.connect(deployer).addModuleDefinition("")).to.be.revertedWith("invalid uri");
        });

        it("Add module def should pass", async () => {
            const tx = await moduleRegistry.connect(deployer).addModuleDefinition(url);
            await expect(tx).to.emit(moduleRegistry, "ModuleDefinitionAdded").withArgs(4);

            let singleModule = await moduleRegistry.getModuleById(4);
            expect(singleModule['metadataURI']).to.eq(url);
            expect(singleModule['id'].toString()).to.eq('4');

            let modules = await moduleRegistry.getAllModules();
            expect(modules.length).to.eq(5);

            expect(modules[4]['metadataURI']).to.eq(url);
            expect(modules[4]['id'].toString()).to.eq('4');
        });
    });
});