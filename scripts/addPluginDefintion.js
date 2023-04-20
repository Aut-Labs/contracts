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
    const pluginRegistryAddress = "0x1b5603687C299f419e1C89B5eB3e4000d87ed1e8"; // mumbai
    const PluginRegistry = await hre.ethers.getContractFactory("PluginRegistry");
    const pluginRegistry = await PluginRegistry.attach(pluginRegistryAddress);
    const onboardingIpfsUrl = "ipfs://bafkreigzreout66gq7mvfhyglxomsfykz7c3ce62awekwqgksw4kulh7iu";
    const discordUrl = "ipfs://bafkreierygsg6i2ue5dot5viledq5veesv36fxph6gn2bzbomlfd7no7qq";
    const openTaskUrl = "ipfs://bafkreib7tvf3yxww35otwai56ov4jzavbpxp2f6mvrlh5voqgukskc4jti";
    const quizUrl = "ipfs://bafkreidaa7oseatq3tau4olbxxkqfb2gqyf534zyslqrnjgftb4xcknr3a";
    const transactionTaskUrl = "ipfs://bafkreigabqeilley66bami64o7pxut2kge6a52xkisnirhld25c5yng3o4";
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
