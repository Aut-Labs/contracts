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

  const MolochV1MembershipChecker = await hre.ethers.getContractFactory("MolochV1MembershipChecker");
  const molochV1MembershipChecker = await MolochV1MembershipChecker.deploy();
  await molochV1MembershipChecker.deployed();
  console.log("molochV1MembershipChecker deployed to:", molochV1MembershipChecker.address);

  const MolochV2MembershipChecker = await hre.ethers.getContractFactory("MolochV2MembershipChecker");
  const molochV2MembershipChecker = await MolochV2MembershipChecker.deploy();
  await molochV2MembershipChecker.deployed();
  console.log("molochV2MembershipChecker deployed to:", molochV2MembershipChecker.address);

  const TributeMembershipChecker = await hre.ethers.getContractFactory("TributeMembershipChecker");
  const tributeMembershipChecker = await TributeMembershipChecker.deploy();
  await tributeMembershipChecker.deployed();
  console.log("tributeMembershipChecker deployed to:", tributeMembershipChecker.address);

  // We get the contract to deploy
  const DAOTypes = await hre.ethers.getContractFactory("DAOTypes");
  const daoTypes = await DAOTypes.deploy();
  await daoTypes.deployed();

  await (await daoTypes.addNewMembershipChecker(swLegacyMembershipChecker.address)).wait();
  await (await daoTypes.addNewMembershipChecker(molochV1MembershipChecker.address)).wait();
  await (await daoTypes.addNewMembershipChecker(molochV2MembershipChecker.address)).wait();
  await (await daoTypes.addNewMembershipChecker(tributeMembershipChecker.address)).wait();

  console.log("DAOTypes deployed to:", daoTypes.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
