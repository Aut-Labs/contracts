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
    const pluginRegistryAddress = ""; // mumbai
    const PluginRegistry = await hre.ethers.getContractFactory("PluginRegistry");
    const pluginRegistry = await PluginRegistry.attach(pluginRegistryAddress);
    const ipfsUrl = "ipfs://bafkreidcjyszmqbzt47vaum6jvppplqocdt4h6xcgj25bg3vz7l426shcy";
    const a = await (
        await pluginRegistry.addPluginDefinition(
            '0xCa05bcE175e9c39Fe015A5fC1E98d2B735fF51d9', ipfsUrl, 0)
    ).wait();
    console.log("addPluginDefinition", a);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
