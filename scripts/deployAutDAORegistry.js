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

  const autIDAddr = hre.network.name == 'mumbai' ? "0xa0322Fe45f3c65180bB57cb9d824aeAE8F517347" : "0xd376E6e323176C6495F9B6dBd6D92EDA8897Aed8";
  const pluginsRegistry = hre.network.name == 'mumbai' ? '0xbBc7f8008429b26A61B48d2103f51Bb6cC53679a' : "";
  const autDAOFactoryAddr = hre.network.name == 'mumbai' ? "0x7FC62bE47a5d74eCF354922d4BEa48240b9C6A9E" : "0x775F7DF7df61f7060ffC4060eBE363D60A951155";

  const AutDAORegistry = await hre.ethers.getContractFactory(
    "AutDAORegistry"
  );
  const autDAORegistry = await AutDAORegistry.deploy(
    trustedForwarder,
    autIDAddr,
    autDAOFactoryAddr,
    pluginsRegistry
  );
  await autDAORegistry.deployed();

  console.log('AutDAORegistry deployed to: ', autDAORegistry.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
