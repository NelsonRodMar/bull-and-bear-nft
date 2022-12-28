# Bull and Bear NFT 

This project is a demonstration of the use of Chainlink VRF, Chainlink Price Feeds and Chainlink Keepers.
<br>
<br>
The VRF is used to mint a random nft in a list. The price feed is used to change the visual of the NFT (bear or bull).
The keeper is used to automatically update the price and then change the URI of the NFT collection.


## How to install

1. Clone the repo


2. Copy/paste the .env.example file and rename it to .env and fill in the variables


3. Run `npm install`


## How to deploy

1. Run the following command 
```bash
npx hardhat run scripts/deploy.js --network mainnet 
OR
npx hardhat run scripts/deployWithFrame.js --network mainnet #use this command to deploy with frame and a hardware wallet
```