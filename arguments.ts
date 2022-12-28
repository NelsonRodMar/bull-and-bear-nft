require('dotenv').config();

// Used to verify contract arguments with Etherscan, don't forget to change the contract address
module.exports = [
    "0xBe6D95479f53E88AC3A1F8019E5F69fD9AFC359E", // priceFeedAddressBTCUSD
    process.env.CHAINLINK_SUBSCRIPTION_ID, // Chainlink subscription ID
    "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",// keyHashChainlink
    100000, // callbackGasLimit
    10 // requestConfirmations
];