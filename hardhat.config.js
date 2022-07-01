const { config } = require("dotenv");

require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require("solidity-coverage");
const { ENV } = require("./config")

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
  solidity: {
    compilers: [
      {
        version: "0.8.4",
        settings: {
          optimizer: {
            enabled: true,
            runs: 1000,
          }
        }
      },
    ],
  },
  gasReporter: {
    enabled: true,
    currency: "USD", 
    token: "MATIC",
    showTimeSpent: true,
    /* outputFile: "docs/this.gasReporter.txt",
    noColors:true, */
    gasPriceApi: "https://api.polygonscan.com/api?module=proxy&action=eth_gasPrice", 
    coinmarketcap: ENV["COINMARKETCAP_API_KEY"],
  },
  etherscan: {
    apiKey: ENV["POLYGONSCAN_API_KEY"],
  }, 
};
