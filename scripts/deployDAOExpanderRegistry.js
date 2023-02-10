// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');


  const goerliTrustedFrowarder = '0xE041608922d06a4F26C0d4c27d8bCD01daf1f792';
  const mumbaiTustedForwarder = '0x69015912AA33720b842dCD6aC059Ed623F28d9f7';
  const trustedForwarder = hre.network.name == 'mumbai' ? mumbaiTustedForwarder : goerliTrustedFrowarder;

  const daoTypesAddr = hre.network.name == 'mumbai' ? "0x814B36802359E0233f38B8A29A96EA9e4c261E37" : "0xD6D405673fF4D1563B9E2dDD3ff7C4B20Af755fc";
  
  const autIDAddr = hre.network.name == 'mumbai' ? "0x5372433d39D469AfC48f338d4A51EE0D43BBfa3f" : "0xd376E6e323176C6495F9B6dBd6D92EDA8897Aed8";
  const daoExpanderFactoryAddr = hre.network.name == 'mumbai' ? "0xc9F1e02C08EDfcbAaAE0C62D79be9c93D3b24b1F" : "0xdaf0E93AAa24b846d8991a314E9466c0c91d9175";
  const pluginsRegistry = hre.network.name == 'mumbai' ? '0xB348681355a3e3AfbF47D08c03A01Cb05c2Cfc1A' : "";

  const DAOExpanderRegistry = await hre.ethers.getContractFactory(
    "DAOExpanderRegistry"
  );
  const daoExpanderRegistry = await DAOExpanderRegistry.deploy(
    trustedForwarder,
    autIDAddr,
    daoTypesAddr,
    daoExpanderFactoryAddr,
    pluginsRegistry
  );
  await daoExpanderRegistry.deployed();

  console.log('DAOExpanderRegistry', daoExpanderRegistry.address);
  
  const a = await daoExpanderRegistry.getDAOExpanders();
  console.log('daoExpanders', a);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
