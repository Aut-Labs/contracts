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
  const SWLegacyMembershipChecker = await hre.ethers.getContractFactory("SWLegacyMembershipChecker");
  const swLegacyMembershipChecker = await SWLegacyMembershipChecker.deploy();

  await swLegacyMembershipChecker.deployed();

  console.log("swLegacyMembershipChecker deployed to:", swLegacyMembershipChecker.address);

  // We get the contract to deploy
  const MembershipTypes = await hre.ethers.getContractFactory("MembershipTypes");
  const membershipTypes = await MembershipTypes.deploy();

  await membershipTypes.deployed();

  const a = await (await membershipTypes.addNewMembershipExtension(swLegacyMembershipChecker.address)).wait();
  console.log(a);

  console.log("MembershipTypes deployed to:", membershipTypes.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
