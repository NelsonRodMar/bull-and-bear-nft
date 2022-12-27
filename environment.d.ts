export {};

declare global {
    namespace NodeJS {
        interface ProcessEnv {
            PRIVATE_KEY: string;
            URL_ALCHEMY_GOERLI: string;
            URL_ALCHEMY_MAINNET: string;
            ETHERSCAN_API_KEY: string;
        }
    }
}
