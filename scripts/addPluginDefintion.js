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
    const pluginRegistryAddress = "0x103A8ab5be0B72331833677F240453171370197F"; // mumbai
    const PluginRegistry = await hre.ethers.getContractFactory("PluginRegistry");
    const pluginRegistry = await PluginRegistry.attach(pluginRegistryAddress);
    const onboardingIpfsUrl = "ipfs://bafkreiesyv4jzvez4kvis6cs6k2xfknmtbi7ld5br5ydy4q5o2i5jyrp3u";
    const discordUrl = "ipfs://bafkreic6jkmskyuxcs7seaqq4e3joluvwa2byh3b6sbczpylf2y2pawycq";
    const openTaskUrl = "ipfs://bafkreibvwhsgccsoes6aivhknpas5zjmmtxvdzdhsbyvpz3fdd2zuxotje";
    const quizUrl = "ipfs://bafkreidyjtoq432npomz34sagyjde3oehvtsqz5tuwlj3ggyf555kwfrwa";
    const transactionTaskUrl = "ipfs://bafkreiblxyyaj7sqzrlkknuhnnsnpifrmzxqfjjfuqvzdymxrepgt6cv7i";
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
