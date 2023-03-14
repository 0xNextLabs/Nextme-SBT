require("@nomicfoundation/hardhat-toolbox");
require("dotenv/config");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.12",
  networks: {
    goerli: {
      url: `${process.env.GOERLI_NODE}${process.env.INFURA_ID}`,
      accounts: [`0x${process.env.DEPLOYER_PRIVATE_KEY}`],
    },
  },
};
