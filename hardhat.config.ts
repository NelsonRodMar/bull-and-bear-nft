import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-etherscan";
require('dotenv').config();

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  defaultNetwork: "goerli",
    networks: {
      goerli: {
        url: process.env.URL_ALCHEMY_GOERLI,
        accounts: [process.env.PRIVATE_KEY]
      },
      mainnet: {
        url: process.env.URL_ALCHEMY_MAINNET,
        accounts: [process.env.PRIVATE_KEY]
      }
    },
    etherscan: {
        apiKey: process.env.ETHERSCAN_API_KEY
    }
};

export default config;