import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require('dotenv').config();

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  defaultNetwork: "goerli",
    networks: {
      goerli: {
        url: process.env.URL_ALCHEMY_GOERLI,
        accounts: [process.env.PRIVATE_KEY]
      }
    }
};

export default config;
