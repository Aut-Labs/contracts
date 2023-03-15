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
    const pluginRegistryAddress = "0x9951eA56186fe1B3a6cE880D85717a598A14086B"; // mumbai
    const PluginRegistry = await hre.ethers.getContractFactory("PluginRegistry");
    const pluginRegistry = await PluginRegistry.attach(pluginRegistryAddress);
    const onboardingIpfsUrl = "ipfs://bafkreibtjnmk3l26rsgl7xhgesutl3y4x5qqloiz7uc4utlpkkgyikd7v4";
    const discordUrl = "ipfs://bafkreihgqnkbatwcso7ssn62p2bj24x6siikj7ii423z3ia34m527xhwwq";
    const openTaskUrl = "ipfs://bafkreigjquuqg5ywat2t3nddq6orakosrnidotwlnagurcuvtmwu4xkzdu";
    const quizUrl = "ipfs://bafkreibczf5den7hxdr4hywlrurhzdqbjd3uyiinnistodmsw5st2zjyzm";
    const transactionTaskUrl = "ipfs://bafkreidxhhc5ta4nnoqdf4u3jxbtnpjnacxrcml7sbblffcd4cd6emdihe";
    const a = await (
        await pluginRegistry.addPluginDefinition(
            '0xCa05bcE175e9c39Fe015A5fC1E98d2B735fF51d9', onboardingIpfsUrl, 0)
    ).wait();
    console.log("addPluginDefinition", a);
    const b = await (
        await pluginRegistry.addPluginDefinition(
            '0xCa05bcE175e9c39Fe015A5fC1E98d2B735fF51d9', discordUrl, 0)
    ).wait();
    console.log("addPluginDefinition", b);

    const c = await (
        await pluginRegistry.addPluginDefinition(
            '0xCa05bcE175e9c39Fe015A5fC1E98d2B735fF51d9', openTaskUrl, 0)
    ).wait();
    console.log("addPluginDefinition", c);

    const d = await (
        await pluginRegistry.addPluginDefinition(
            '0xCa05bcE175e9c39Fe015A5fC1E98d2B735fF51d9', quizUrl, 0)
    ).wait();
    console.log("addPluginDefinition", d);

    const e = await (
        await pluginRegistry.addPluginDefinition(
            '0xCa05bcE175e9c39Fe015A5fC1E98d2B735fF51d9', transactionTaskUrl, 0)
    ).wait();
    console.log("addPluginDefinition", e);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
