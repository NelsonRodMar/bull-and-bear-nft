// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract BullAndBear is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable, AutomationCompatible {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    struct uriStruct {
        string[] uri;
        uint256 price;
    }

    event TokensUpdated(string trend);

    // IPFS URIs for the dynamic nft graphics/metadata.
    string[] bullUrisIpfs = [
    "https://ipfs.io/ipfs/QmRXyfi3oNZCubDxiVFre3kLZ8XeGt6pQsnAQRZ7akhSNs?filename=gamer_bull.json",
    "https://ipfs.io/ipfs/QmRJVFeMrtYS2CUVUM2cHJpBV5aX2xurpnsfZxLTTQbiD3?filename=party_bull.json",
    "https://ipfs.io/ipfs/QmdcURmN1kEEtKgnbkVJJ8hrmsSWHpZvLkRgsKKoiWvW9g?filename=simple_bull.json"
    ];
    string[] bearUrisIpfs = [
    "https://ipfs.io/ipfs/Qmdx9Hx7FCDZGExyjLR6vYcnutUR8KhBZBnZfAPHiUommN?filename=beanie_bear.json",
    "https://ipfs.io/ipfs/QmTVLyTSuiKGUEmb88BgXG3qNC8YgpHZiFbjHrXKH3QHEu?filename=coolio_bear.json",
    "https://ipfs.io/ipfs/QmbKhBXVWmwrYsTPFYfroR2N7NAekAMxHUVg2CWks7i9qj?filename=simple_bear.json"
    ];

    AggregatorV3Interface internal priceFeedBTCUSD;
    uint public immutable interval = 15*60*1000; // 15 minutes
    uint public lastTimeStamp;
    int public currentPrice;

    constructor(address _priceFeedBTCUSD) ERC721("BullAndBear", "BBTK") {
        lastTimeStamp = block.timestamp;
        priceFeedBTCUSD = AggregatorV3Interface(_priceFeedBTCUSD);
        currentPrice = getLatestPrice();
    }

    function safeMint(address to) public {
        require(_tokenIdCounter.current() < 101, "All tokens have been minted");
        // Current counter value will be the minted token's token ID.
        uint256 tokenId = _tokenIdCounter.current();

        // Increment it so next time it's correct when we call .current()
        _tokenIdCounter.increment();

        // Mint the token
        _safeMint(to, tokenId);

        // First bull NFT for now
        string memory defaultUri = bullUrisIpfs[0];
        _setTokenURI(tokenId, defaultUri);
    }


    // Chainlink functions
    function checkUpkeep(bytes calldata) external view override
    returns (bool upkeepNeeded, bytes memory)
    {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
    }

    function performUpkeep(bytes calldata) external override {
        if ((block.timestamp - lastTimeStamp) > interval) {
            lastTimeStamp = block.timestamp;
            int latestPrice = getLatestPrice();
            if (latestPrice == currentPrice) {
                // No change
                return;
            }

            if (latestPrice < currentPrice) {
                // bear
                updateAllTokenUris("bear");

            } else {
                // bull
                updateAllTokenUris("bull");
            }
            currentPrice = latestPrice;
        }
    }

    // Only Owner functions
    function updatePriceFeed(address _priceFeedBTCUSD) public onlyOwner {
        require(_priceFeedBTCUSD != address(0), "Price feed address cannot be 0");
        priceFeedBTCUSD = AggregatorV3Interface(_priceFeedBTCUSD);
    }

    function updateInterval(uint _interval) public onlyOwner {
        require(_interval > 0, "Price feed address cannot be 0");
        interval = _interval;
    }

    // Helpers
    function getLatestPrice() public view returns (int256) {
        (
        /*uint80 roundID*/,
        int price,
        /*uint startedAt*/,
        /*uint timeStamp*/,
        /*uint80 answeredInRound*/
        ) = priceFeedBTCUSD.latestRoundData();

        return price;
    }

    function updateAllTokenUris(string memory trend) internal {
        if (compareStrings("bear", trend)) {
            for (uint i = 0; i < _tokenIdCounter.current() ; i++) {
                _setTokenURI(i, bearUrisIpfs[0]);
            }

        } else {
            for (uint i = 0; i < _tokenIdCounter.current() ; i++) {
                _setTokenURI(i, bullUrisIpfs[0]);
            }
        }
        emit TokensUpdated(trend);
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
    internal override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}