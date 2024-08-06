const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config();

const mnemonic = process.env.MNEMONIC;

const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
    },
    goerli: {
      provider: () => new HDWalletProvider(mnemonic, `https://goerli.infura.io/v3/${infuraProjectId}`),
      network_id: 5,
      gas: 5500000,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    sepolia: {
      provider: () => new HDWalletProvider(mnemonic, `https://eth-sepolia.g.alchemy.com/v2/${ALCHEMY_API_KEY}`),
      network_id: 11155111,
      gas: 4465030,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    mainnet: {
      provider: () => new HDWalletProvider(mnemonic, `https://mainnet.infura.io/v3/${infuraProjectId}`),
      network_id: 1,
      gas: 5500000,
      gasPrice: 20000000000,  // 20 gwei
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    },
  },

  mocha: {
    timeout: 100000
  },

  compilers: {
    solc: {
      version: "^0.8.18",
      docker: false,
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        },
        evmVersion: "london"
      }
    }
  },

  // db: {
  //   enabled: false,
  //   host: "127.0.0.1",
  //   adapter: {
  //     name: "sqlite",
  //     settings: {
  //       directory: ".db"
  //     }
  //   }
  // },

  plugins: [
    'truffle-plugin-verify'
  ],

  api_keys: {
    alchemy: process.env.ALCHEMY_API_KEY
  },

  contracts_directory: './contracts/',
  contracts_build_directory: './build/contracts/',
  migrations_directory: './migrations/',
};
