import { ethers } from "hardhat";

async function main() {
  // This script is just for deploying with Hardware Wallets.
  // Deploy with Frame src : https://github.com/NomicFoundation/hardhat/issues/1159#issuecomment-789310120

  // Create a Frame connection
  const ethProvider = require('eth-provider') // eth-provider is a simple EIP-1193 provider
  const frame = ethProvider('frame') // Connect to Frame

  // Use `getDeployTransaction` instead of `deploy` to return deployment data
  const BullAndBear = await ethers.getContractFactory('BullAndBear')
  const bullAndBear = await BullAndBear.getDeployTransaction()

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
