// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Asset {
    address public assetAddress;
    string public name;
    string public symbol;
    uint256 public openingTime;
    uint256 public closingTime;
    uint256 public resultTime;
    uint256 public betPrice;
    address public betSetter;

    event AssetCreated(
        address indexed assetAddress,
        string name,
        string symbol,
        uint256 openingTime,
        uint256 closingTime,
        uint256 resultTime,
        uint256 betPrice,
        address betSetter
    );

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _openingTime,
        uint256 _closingTime,
        uint256 _resultTime,
        uint256 _betPrice,
        address _betSetter
    ) {
        assetAddress = address(this);
        name = _name;
        symbol = _symbol;
        openingTime = _openingTime;
        closingTime = _closingTime;
        resultTime = _resultTime;
        betPrice = _betPrice;
        betSetter = _betSetter;

        emit AssetCreated(
            assetAddress,
            name,
            symbol,
            openingTime,
            closingTime,
            resultTime,
            betPrice,
            betSetter
        );
    }

    // Getter functions for state variables
    function getBetPrice() public view returns (uint256) {
        return betPrice;
    }

    // Setter functions to update asset details
    function setName(string memory _name) public {
        require(msg.sender == betSetter, "Only betSetter can update the name");
        name = _name;
    }

    function setSymbol(string memory _symbol) public {
        require(msg.sender == betSetter, "Only betSetter can update the symbol");
        symbol = _symbol;
    }

    function setOpeningTime(uint256 _openingTime) public {
        require(msg.sender == betSetter, "Only betSetter can update the opening time");
        openingTime = _openingTime;
    }

    function setClosingTime(uint256 _closingTime) public {
        require(msg.sender == betSetter, "Only betSetter can update the closing time");
        closingTime = _closingTime;
    }

    function setResultTime(uint256 _resultTime) public {
        require(msg.sender == betSetter, "Only betSetter can update the result time");
        resultTime = _resultTime;
    }

    function setBetPrice(uint256 _betPrice) public {
        require(msg.sender == betSetter, "Only betSetter can update the bet price");
        betPrice = _betPrice;
    }
}
