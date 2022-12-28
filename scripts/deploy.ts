import {ethers, network} from "hardhat";
import * as readline from 'readline';
require('dotenv').config();

async function main() {
  // Check doc here for price feed address : https://docs.chain.link/docs/ethereum-addresses/
  let priceFeedAddressBTCUSD, keyHashChainlink, callbackGasLimit = 100000, requestConfirmations = 3
  console.log("Network name : ", network.name);

  if (network.name === "goerli") {
    priceFeedAddressBTCUSD = "0xA39434A63A52E749F02807ae27335515BA4b07F7"; // Price feed BTC/USD on Goerli
    keyHashChainlink = "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15" // 150 gwei Key Hash
  } else if (network.name === "mainnet") {
    priceFeedAddressBTCUSD = "0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c"; // Price feed BTC/USD on Mainnet
    keyHashChainlink = "0xff8dedfbfa60af186cf3c830acbc32c05aae823045ae5ea7da1e45fbfaba4f92" // 500 gwei Key Hash
  } else {
    throw new Error("Network not supported");
  }

  let rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });
  // Verifies that user have fullfiled VRFCoordinator address for the network
  rl.setPrompt('Have you fullfiled the VrfCoordinator address for '+ network.name +' ? [y/n] ');
  rl.prompt();
  await new Promise(() => {
    rl.on('line', (userInput) => {
      console.log(`Received: ${userInput}`);
      if (userInput !== "y")  {
        console.log('Script abort !');
        process.exit(1);
      }
      rl.close();
    });
  });

  priceFeedAddressBTCUSD = "0xBe6D95479f53E88AC3A1F8019E5F69fD9AFC359E"; // Price feed Mock address

  const BullAndBear = await ethers.getContractFactory("BullAndBear");
 const bullAndBear = await BullAndBear.deploy(
      priceFeedAddressBTCUSD,
      process.env.CHAINLINK_SUBSCRIPTION_ID,
      keyHashChainlink,
      callbackGasLimit,
      requestConfirmations
  );
  await bullAndBear.deployed();

  console.log(`BullAndBear deployed to ${bullAndBear.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
