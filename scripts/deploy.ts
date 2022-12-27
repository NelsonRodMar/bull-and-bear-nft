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
  priceFeedAddressBTCUSD = "0xBe6D95479f53E88AC3A1F8019E5F69fD9AFC359E"; // Price feed Mock address

  const BullAndBear = await ethers.getContractFactory("BullAndBear");
  const bullAndBear = await BullAndBear.deploy(priceFeedAddressBTCUSD);
  console.log("BullAndBear deploy in progress...", bullAndBear.address);

  await bullAndBear.deployed();

  console.log(`BullAndBear deployed to ${bullAndBear.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
