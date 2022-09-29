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

  const TributeMembershipChecker = await hre.ethers.getContractFactory(
    "TributeMembershipChecker"
  );
  const tributeMembershipChecker = await TributeMembershipChecker.deploy();
  await tributeMembershipChecker.deployed();
  console.log(
    "tributeMembershipChecker deployed to:",
    tributeMembershipChecker.address
  );

  // We get the contract to deploy
  const daoTypeAddress = "0xD6D405673fF4D1563B9E2dDD3ff7C4B20Af755fc"; // goerli
  const DAOTypes = await hre.ethers.getContractFactory("DAOTypes");
  const daoTypes = await DAOTypes.attach(daoTypeAddress);

  await (
    await daoTypes.addNewMembershipChecker(
      tributeMembershipChecker.address
    )
  ).wait();
  console.log("tributeMembershipChecker", tributeMembershipChecker.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
