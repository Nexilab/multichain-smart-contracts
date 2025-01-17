require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
require("dotenv").config();
require("@ericxstone/hardhat-blockscout-verify");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.19",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 10000000,
          },
        },
      },
      {
        version: "0.5.16",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.5.16",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },

  blockscoutVerify: {
    blockscoutURL: "http://185.173.129.244:4000/",
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
    plgchain: {
      chainId: 242,
      url: process.env.URL,
      accounts: [process.env.PRIVATE_KEY],
    },
    nexichain: {
      chainId: 4242,
      url: "http://185.128.137.243:18545",
      accounts: [process.env.PRIVATE_KEY],
    },
    polygon: {
      chainId: 137,
      url: "https://polygon-mainnet.blastapi.io/2579f480-3a52-4cec-b363-bbfaecb15ade",
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: {
      plgchain: "aaaaaaaaaaaa",
      nexichain: "aaaaaaaaaaaa",
      polygon: "IIVTQA11WV6NS1NY54RB7J5EFUIW88TNII",
    },

    customChains: [
      {
        network: "plgchain",
        chainId: 242,
        urls: {
          apiURL: "http://185.128.137.241:4000/api",
          browserURL: "http://185.128.137.241:4000",
        },
      },
      {
        network: "nexichain",
        chainId: 4242,
        urls: {
          apiURL: "http://185.173.129.242:4000/api",
          browserURL: "http://185.173.129.242:4000",
        },
      },
      {
        network: "polygon",
        chainId: 137,
        urls: {
          apiURL: "https://api.polygonscan.com",
          browserURL: "https://www.polygonscan.com",
        },
      },
    ],
  },
};
