// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceFeed {
    // Define mapping to store the Chainlink price feeds for different assets
    mapping(string => AggregatorV3Interface) private priceFeeds;

    // Define events for adding and updating price feeds
    event PriceFeedAdded(string symbol, address priceFeedAddress);
    event PriceFeedUpdated(string symbol, address priceFeedAddress);

    constructor() {
        // Add default price feeds for BTC and ETH
        addPriceFeed("BTC", 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43);
        addPriceFeed("ETH", 0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    // Function to add or update price feed for an asset
    function addPriceFeed(string memory symbol, address priceFeedAddress) public {
        priceFeeds[symbol] = AggregatorV3Interface(priceFeedAddress);
        emit PriceFeedAdded(symbol, priceFeedAddress);
    }

    // Function to update price feed for an asset
    function updatePriceFeed(string memory symbol, address priceFeedAddress) public {
        require(address(priceFeeds[symbol]) != address(0), "Price feed does not exist");
        priceFeeds[symbol] = AggregatorV3Interface(priceFeedAddress);
        emit PriceFeedUpdated(symbol, priceFeedAddress);
    }

    // Function to get the latest price for a given asset symbol
    function getLatestPrice(string memory symbol) public view returns (int) {
        AggregatorV3Interface dataFeed = priceFeeds[symbol];
        require(address(dataFeed) != address(0), "Price feed not found for symbol");
        return _getPrice(dataFeed);
    }

    // Internal function to get price from the price feed
    function _getPrice(AggregatorV3Interface dataFeed) internal view returns (int) {
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return price;
    }
}
