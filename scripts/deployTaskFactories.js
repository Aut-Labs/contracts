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

  

  // We get the contract to deploy
  const QuestOpenTaskFactory = await hre.ethers.getContractFactory("QuestOpenTaskFactory");
  const questOpenTaskFactory = await QuestOpenTaskFactory.deploy();
  await questOpenTaskFactory.deployed();
  console.log("QuestOpenTaskFactory deployed to:", questOpenTaskFactory.address);


  const QuestOffchainTaskFactory = await hre.ethers.getContractFactory("QuestOffchainTaskFactory");
  const questOffchainTaskFactory = await QuestOffchainTaskFactory.deploy();
  await questOffchainTaskFactory.deployed();
  console.log("QuestOffchainTaskFactory deployed to:", questOffchainTaskFactory.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
