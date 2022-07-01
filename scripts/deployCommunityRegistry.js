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

  const autIDAddr = "0xfC54AdC82142d3B52895840702fe968DcAE53Fee";
  const membershipTypesAddr = "0x00fbB8e663614f16e85df9634fd116aecF4872F9";
  const daoAddr = '0x7DeF7A0C6553B9f7993a131b5e30AB59386837E0'

  const CommunityRegistry = await hre.ethers.getContractFactory(
    "CommunityRegistry"
  );
  const communityRegistry = await CommunityRegistry.deploy(
    autIDAddr,
    membershipTypesAddr
  );
  await communityRegistry.deployed();

  console.log('CommunityRegistry', communityRegistry.address);
  
  // await (
  //   await communityRegistry.createCommunity(
  //     1,
  //     daoAddr,
  //     1,
  //     "bafkreidjy6xlyf2he4iopzijy7bws3yl34xhwh726ca2xd7temqoqkz6xy",
  //     8
  //   )
  // ).wait();

  // We get the contract to deploy

  const a = await communityRegistry.getCommunities();
  console.log(a);

  console.log("CommunityExtension deployed to:", communityExtension.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
