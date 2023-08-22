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
    const pluginRegistryAddress = "0xCe8898c5716c671F929569A26762798466BECba5"; // mumbai
    const PluginRegistry = await hre.ethers.getContractFactory("PluginRegistry");
    const pluginRegistry = await PluginRegistry.attach(pluginRegistryAddress);
    const onboardingIpfsUrl = "ipfs://bafkreig3gwhmraeljunek6rw3vynsbxapmwdmtzaov6uwcsq4qz6t2kmny";
    const discordUrl = "ipfs://bafkreic6s52eavmst3w7vebsdzl76a55wbm3asq6qujubjh6xh3323u7f4";
    const openTaskUrl = "ipfs://bafkreie45ntwx6trhl4azaixj6st64rcghrnscf2mnlahihctri6ospgte";
    const quizUrl = "ipfs://bafkreign362uxbfxfmczqd73accyqvfllmf5p47lxyubmdxylhin5xdazi";
    const transactionTaskUrl = "ipfs://bafkreidlrxr57x7f3pfen35kzorqxnkfatuc5brofgpztty3qi5eis6f6a";
    const a = await (
        await pluginRegistry.addPluginDefinition(
            '0xed05b8f5e989849b3de4ef63D1e498F8BEFef43C', onboardingIpfsUrl, 0, true, [3])
    ).wait();
    console.log("addPluginDefinition", a);
    const b = await (
        await pluginRegistry.addPluginDefinition(
            '0xed05b8f5e989849b3de4ef63D1e498F8BEFef43C', discordUrl, 0, true, [])
    ).wait();
    console.log("addPluginDefinition", b);

    const c = await (
        await pluginRegistry.addPluginDefinition(
            '0xed05b8f5e989849b3de4ef63D1e498F8BEFef43C', openTaskUrl, 0,  true, [])
    ).wait();
    console.log("addPluginDefinition", c);

    const d = await (
        await pluginRegistry.addPluginDefinition(
            '0xed05b8f5e989849b3de4ef63D1e498F8BEFef43C', quizUrl, 0,  true, [])
    ).wait();
    console.log("addPluginDefinition", d);

    const e = await (
        await pluginRegistry.addPluginDefinition(
            '0xed05b8f5e989849b3de4ef63D1e498F8BEFef43C', transactionTaskUrl, 0, true, [])
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
