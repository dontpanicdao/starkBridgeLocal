require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
const GOERLIURL = process.env.GOERLIURL;
const PRIVKEY = process.env.PRIVKEY;

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 100
      }
    }
  },
  networks: {
    goerli: {
      url: GOERLIURL,
      accounts: [`${PRIVKEY}`],
      gas: 5000000,
      gasPrice: 25000000000, // 25 gwei
      // gasPrice: 250000000000, // 250 gwei
    }
  },
  mocha: {
    timeout: 200000
  }
};