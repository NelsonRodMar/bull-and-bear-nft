import { ethers } from "hardhat";

async function main() {

  const BullAndBear = await ethers.getContractFactory("BullAndBear");
  const bullAndBear = await BullAndBear.deploy();

  await bullAndBear.deployed();

  console.log(`BullAndBear deployed to ${bullAndBear.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
