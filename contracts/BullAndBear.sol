// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";


contract BullAndBear is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable, AutomationCompatible, VRFConsumerBaseV2 {
    //Event
    event TokensUpdated(string trend);
    event VRFRequestSent(uint256 requestId, uint32 numWords);
    event VRFRequestFulfilled(uint256 requestId, uint256[] randomWords);
    event IPFSIdRequested(uint256 requestId, uint256 tokenId);
    event IPFSIdReceived(uint256 requestId, uint256 tokenId, uint256 ipfsId);

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    uint public constant MAX_SUPPLY = 101;

    // IPFS URIs for the dynamic nft graphics/metadata.
    string waitingVRF = "https://ipfs.io/ipfs/QmUveY3PgfLD9TahrAEH2WieCG1PfU9Ybdq9WbZe8wXwvQ?filename=waiting_vrf.json";
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
    // Chainlink Price Feeds
    AggregatorV3Interface internal priceFeedBTCUSD;
    uint public interval = 10*60; // 10 minutes
    uint public lastTimeStamp;
    int public currentPrice;
    string public lastTrend = "bear";
    // Chainlink VRF
    VRFCoordinatorV2Interface COORDINATOR;
    uint256 private constant WAITING_VRF = 42;
    uint64 public subscriptionId;
    bytes32 public keyHash;
    uint32 public callbackGasLimit;
    uint16 public requestConfirmations;
    // map request ID to token ID
    mapping(uint256 => uint256) public requestIdToTokenId;
    // map token ID to ipfs ID
    mapping(uint256 => uint256) public tokenIdToIndexIPFS;



    constructor(
        address _priceFeedBTCUSD,
        uint64 _subscriptionId,
        bytes32 _keyHash,
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations
    )
    VRFConsumerBaseV2(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D)
    ERC721("BullAndBear", "BBTK")
    {
        lastTimeStamp = block.timestamp;
        priceFeedBTCUSD = AggregatorV3Interface(_priceFeedBTCUSD);
        currentPrice = getLatestPrice();
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        callbackGasLimit = _callbackGasLimit;
        requestConfirmations = _requestConfirmations;
        COORDINATOR = VRFCoordinatorV2Interface(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D);
    }

    function safeMint(address _to) public {
        require(_tokenIdCounter.current() < MAX_SUPPLY, "All tokens have been minted");
        // Current counter value will be the minted token's token ID.
        uint256 tokenId = _tokenIdCounter.current();

        // Increment it so next time it's correct when we call .current()
        _tokenIdCounter.increment();


        // Request the VRF IPFS id
        uint requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            1
        );
        requestIdToTokenId[requestId] = tokenId;
        tokenIdToIndexIPFS[tokenId] = WAITING_VRF;

        emit IPFSIdRequested(requestId,tokenId);

        // Mint the token
        _safeMint(_to, tokenId);

        // Set waiting VRF URI
        string memory defaultUri = waitingVRF;
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
                lastTrend = "bear";
            } else {
                // bull
                updateAllTokenUris("bull");
                lastTrend = "bull";
            }
            currentPrice = latestPrice;
        }
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        uint tokenId = requestIdToTokenId[_requestId];
        require(tokenIdToIndexIPFS[tokenId] == WAITING_VRF, "request not found");
        uint256 ipfsId = (_randomWords[0] % 3); // 0-2
        tokenIdToIndexIPFS[tokenId] = ipfsId;

        if (compareStrings("bull", lastTrend)) {
            _setTokenURI(tokenId, bullUrisIpfs[ipfsId]);
        } else {
            _setTokenURI(tokenId, bearUrisIpfs[ipfsId]);
        }

        emit IPFSIdReceived(_requestId, tokenId, ipfsId);
    }

    // Only Owner functions
    function updatePriceFeed(address _priceFeedBTCUSD) external onlyOwner {
        require(_priceFeedBTCUSD != address(0), "Price feed address cannot be 0");
        priceFeedBTCUSD = AggregatorV3Interface(_priceFeedBTCUSD);
    }

    function updateInterval(uint _interval) external onlyOwner {
        require(_interval > 0, "Interval update cannot be 0");
        interval = _interval;
    }


    function updateVRFData(
        uint64 _subscriptionId,
        bytes32 _keyHash,
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations) external onlyOwner
    {
        subscriptionId = _subscriptionId;
        keyHash = _keyHash;
        callbackGasLimit = _callbackGasLimit;
        requestConfirmations = _requestConfirmations;
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
                uint256 ipfsId = tokenIdToIndexIPFS[i];
                _setTokenURI(i, bearUrisIpfs[ipfsId]);
            }

        } else {
            for (uint i = 0; i < _tokenIdCounter.current() ; i++) {
                uint256 ipfsId = tokenIdToIndexIPFS[i];
                _setTokenURI(i, bearUrisIpfs[ipfsId]);
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