require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
require("dotenv").config();
require("@ericxstone/hardhat-blockscout-verify");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  blockscoutVerify: {
    blockscoutURL: "http://46.102.129.40:3000",
    contracts: {
      CashUSDV3: {
        //compilerVersion: SOLIDITY_VERSION."0.8.12", // checkout enum SOLIDITY_VERSION
        optimization: false,
        //evmVersion: EVM_VERSION.<EVM_VERSION>, // checkout enum SOLIDITY_VERSION
        // optimizationRuns: 999999,
      },
    },
  },
  networks: {
    Nexi: {
      url: process.env.URL,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: {
      Nexi: "aaaaaaaaaaaa",
    },

    customChains: [
      {
        network: "Nexi",
        chainId: 4242,
        urls: {
          apiURL: "http://46.102.129.40:3000/api",
          browserURL: "http://46.102.129.40:3000",
        },
      },
    ],
  },
};
