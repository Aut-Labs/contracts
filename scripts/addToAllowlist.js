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


    // We get the contract to deploy
    const devAllowlistAddress = "0x3Aa3c3cd9361a39C651314261156bc7cdB52B618"; // mumbai
    const prodAllowlistAddress = '0xc30B5B04DB59A91F8e2058Bf998C0A4F827A8C2A';
    const Allowlist = await hre.ethers.getContractFactory("Allowlist");
    const allowlist = await Allowlist.attach(devAllowlistAddress);

    const a = await (
      await allowlist.addToAllowlist(
        '0xE79A5fbc800ABA2074b0e54c68e51a5F6a38E07e' // tao
      )
    ).wait();
    console.log("allowlistTx", a);
  }

  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
