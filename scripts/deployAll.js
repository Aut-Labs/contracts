// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {

  const goerliTrustedFrowarder = '0xE041608922d06a4F26C0d4c27d8bCD01daf1f792';
  const mumbaiTustedForwarder = '0x69015912AA33720b842dCD6aC059Ed623F28d9f7';
  const trustedForwarder = hre.network.name == 'mumbai' ? mumbaiTustedForwarder : goerliTrustedFrowarder;

  const AutID = await hre.ethers.getContractFactory("AutID");
  const autID = await hre.upgrades.deployProxy(AutID, [trustedForwarder], { initializer: 'initialize' });

  await autID.deployed();

  const NovaFactory = await hre.ethers.getContractFactory(
    "NovaFactory"
  );
  const novaFactory = await NovaFactory.deploy();
  await novaFactory.deployed();

  const ModuleRegistry = await hre.ethers.getContractFactory("ModuleRegistry");
  const moduleRegistry = await ModuleRegistry.deploy();
  await moduleRegistry.deployed();

  const PluginRegistry = await hre.ethers.getContractFactory("PluginRegistry");
  const pluginRegistry = await PluginRegistry.deploy(moduleRegistry.address);
  await pluginRegistry.deployed();

  const NovaRegistry = await hre.ethers.getContractFactory(
    "NovaRegistry"
  );
  const novaRegistry = await NovaRegistry.deploy(
    trustedForwarder,
    autID.address,
    novaFactory.address,
    pluginRegistry.address
  );
  await novaRegistry.deployed();

  console.log(`MUMBAI_AUT_ID_ADDRESS=${autID.address}`);
  // console.log(`MUMBAI_DAO_REGISTRY_ADDRESS=${daoExpanderRegistry.address}`);
  // console.log(`MUMBAI_DAO_FACTORY_ADDRESS=${daoExpanderFactory.address}`);
  console.log(`MUMBAI_AUT_DAO_REGISTRY_ADDRESS=${novaRegistry.address}`);
  console.log(`MUMBAI_AUT_DAO_FACTORY_ADDRESS=${novaFactory.address}`);
  console.log(`MUMBAI_DAO_TYPES_ADDRESS=0x814B36802359E0233f38B8A29A96EA9e4c261E37`);
  console.log(`MUMBAI_HACKERS_DAO_ADDRESS=0x8eA20de15Db87Be1a8B20Da5ebD785a4a9BE9690`);
  console.log(`MUMBAI_PLUGIN_REGISTRY_ADDRESS=${pluginRegistry.address}`);
  console.log(`MUMBAI_MODULE_REGISTRY_ADDRESS=${moduleRegistry.address}`);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
