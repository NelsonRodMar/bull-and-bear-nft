import {ethers, network} from "hardhat";

async function main() {
  // Check doc here for price feed address : https://docs.chain.link/docs/ethereum-addresses/
  let priceFeedAddressBTCUSD
  console.log("Network name : ", network.name);
  if (network.name === "goerli") {
    priceFeedAddressBTCUSD = "0xA39434A63A52E749F02807ae27335515BA4b07F7"; // Price feed BTC/USD on Goerli
  } else if (network.name === "mainnet") {
    priceFeedAddressBTCUSD = "0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c"; // Price feed BTC/USD on Mainnet
  } else {
    throw new Error("Network not supported");
  }
  priceFeedAddressBTCUSD = "0xBe6D95479f53E88AC3A1F8019E5F69fD9AFC359E";

  // This script is just for deploying with Hardware Wallets.
  // Deploy with Frame src : https://github.com/NomicFoundation/hardhat/issues/1159#issuecomment-789310120

  // Create a Frame connection
  const ethProvider = require('eth-provider') // eth-provider is a simple EIP-1193 provider
  const frame = ethProvider('frame') // Connect to Frame

  // Use `getDeployTransaction` instead of `deploy` to return deployment data
  const BullAndBear = await ethers.getContractFactory('BullAndBear')
  const bullAndBear = await BullAndBear.getDeployTransaction(priceFeedAddressBTCUSD)

  // Set `tx.from` to current Frame account
  bullAndBear.from = (await frame.request({ method: 'eth_requestAccounts' }))[0]

  // Sign and send the transaction using Frame
  const result = await frame.request({ method: 'eth_sendTransaction', params: [bullAndBear] })
  result.wait(); // Wait for the transaction to be mined

  console.log(`BullAndBear deployed to ${result.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
