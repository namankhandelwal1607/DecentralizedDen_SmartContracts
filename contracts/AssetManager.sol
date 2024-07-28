// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Asset.sol";

contract AssetManager {
    address[] public assetAddresses;

    function createAsset(
        string memory name,
        string memory symbol,
        uint256 openingTime,
        uint256 closingTime,
        uint256 resultTime,
        uint256 betPrice
    ) public returns (address) {
        Asset newAsset = new Asset(
            name,
            symbol,
            openingTime,
            closingTime,
            resultTime,
            betPrice,
            msg.sender
        );
        address assetAddress = address(newAsset);
        assetAddresses.push(assetAddress);
        return assetAddress;
    }

    function getAssetDetails(address assetAddress) public view returns (
        string memory name,
        string memory symbol,
        uint256 openingTime,
        uint256 closingTime,
        uint256 resultTime,
        uint256 betPrice,
        address betSetter
    ) {
        Asset asset = Asset(assetAddress);
        return (
            asset.name(),
            asset.symbol(),
            asset.openingTime(),
            asset.closingTime(),
            asset.resultTime(),
            asset.getBetPrice(),
            asset.betSetter()
        );
    }

    function getAllAssets() public view returns (address[] memory) {
        return assetAddresses;
    }

    function assetsLength() public view returns (uint256) {
        return assetAddresses.length;
    }
}
