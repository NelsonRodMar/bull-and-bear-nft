require('dotenv').config();

// Used to verify contract arguments with Etherscan, don't forget to change the contract address
module.exports = [
    "0xA39434A63A52E749F02807ae27335515BA4b07F7", // priceFeedAddressBTCUSD
    process.env.CHAINLINK_SUBSCRIPTION_ID, // Chainlink subscription ID
    "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",// keyHashChainlink
    100000, // callbackGasLimit
    3 // requestConfirmations
];