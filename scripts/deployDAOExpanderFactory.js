// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  
  const DAOExpanderFactory = await hre.ethers.getContractFactory(
    "DAOExpanderFactory"
  );
  const daoExpanderFactory = await DAOExpanderFactory.deploy();
  await daoExpanderFactory.deployed();

  console.log('DAOExpanderFactory deployed to:', daoExpanderFactory.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
