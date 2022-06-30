require("dotenv").config();

require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");
require("hardhat-contract-sizer");
// const defaultNetwork = "mumbai";

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  defaultNetwork: "mumbai",
  networks: {
    hardhat: {},
    mumbai: {
      url: "https://matic-mumbai.chainstacklabs.com/",
      accounts: [process.env.MNEMONIC],
    },
  },

  // defaultNetwork,
  // networks: {
  //   localhost: {
  //     url: "http://localhost:7545",
  //     /*
  //       notice no mnemonic here? it will just use account 0 of the hardhat node to deploy
  //       (you can put in a mnemonic here to set the deployer locally)
  //     */
  //   },
  //   matic: {
  //     url: "https://polygon-rpc.com/",
  //     accounts: [process.env.MNEMONIC],
  //   },
  //   kovan: {
  //     url: "https://kovan.infura.io/v3/779285194bd146b48538d269d1332f20",
  //     gasPrice: 1000000000,
  //     accounts: [process.env.MNEMONIC],
  //   },
  //   mumbai: {
  //     url: "https://matic-mumbai.chainstacklabs.com/",
  //     gasPrice: 10000000000,
  //     accounts: [process.env.MNEMONIC],
  //   },
  // },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
  },
  mocha: {
    timeout: 40000,
  },
};
