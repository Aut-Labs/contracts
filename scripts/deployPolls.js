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

  const Polls = await hre.ethers.getContractFactory(
    "Polls"
  );

  const communityExtension = '0xdD0Ef39D42Bb5B679a2734aa5a53380B9764c928';
  const discordBotAddresss = '0x8195cF28994814206096a4878892f3993955deb1';

  const polls = await Polls.deploy(communityExtension, discordBotAddresss);
  await polls.deployed();

  console.log('Polls', polls.address);
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
