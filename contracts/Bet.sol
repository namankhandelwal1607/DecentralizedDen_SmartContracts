// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AssetManager.sol";
import "./Asset.sol";
import "./PriceFeed.sol";

contract Bet {
    struct BetInfo {
        address userAddress;
        address assetAddress;
        uint256 amountPaid;
        uint256 estimate;
        uint256 winningAmount;
    }

    BetInfo[] public bets;
    AssetManager public assetManager;
    PriceFeed public priceFeed;
    uint256 public totalBalance;
    mapping(address => uint256) public assetBalances;

    event BetPlaced(
        address indexed userAddress,
        address indexed assetAddress,
        uint256 amountPaid,
        uint256 estimate
    );

    event Deposit(address indexed sender, uint256 amount);
    event FundsDistributed(
        address indexed assetAddress,
        address indexed address1,
        address indexed address2,
        uint256 amount1,
        uint256 amount2,
        uint256 amount3
    );

    error IncorrectPaymentAmount(uint256 sent, uint256 required);

    constructor(address _assetManagerAddress, address  _priceFeed) {  
        assetManager = AssetManager(_assetManagerAddress);
        priceFeed = PriceFeed(_priceFeed);
    }

    function setBet(address assetAddress, uint256 estimate) public payable {
        (
            ,
            ,
            ,
            ,
            ,
            uint256 betPrice,
            address betSetter
        ) = assetManager.getAssetDetails(assetAddress);

        require(betPrice > 0, "Bet price is not set or invalid");
        require(betSetter != address(0), "Invalid bet setter");

        if (msg.value != betPrice) {
            revert IncorrectPaymentAmount(msg.value, betPrice);
        }

        BetInfo memory newBet = BetInfo({
            userAddress: msg.sender,
            assetAddress: assetAddress,
            amountPaid: msg.value,
            estimate: estimate,
            winningAmount: 0
        });

        bets.push(newBet);

        totalBalance += msg.value;
        assetBalances[assetAddress] += msg.value;

        emit BetPlaced(msg.sender, assetAddress, msg.value, estimate);
        emit Deposit(msg.sender, msg.value);
    }

    function getBalance() public view returns (uint256) {
        return totalBalance;
    }

    function getAssetBalance(address assetAddress) public view returns (uint256) {
        return assetBalances[assetAddress];
    }

    receive() external payable {
        totalBalance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function getBet(uint256 index) public view returns (
        address,
        address,
        uint256,
        uint256,
        uint256
    ) {
        require(index < bets.length, "Bet index out of bounds");
        BetInfo storage bet = bets[index];
        return (
            bet.userAddress,
            bet.assetAddress,
            bet.amountPaid,
            bet.estimate,
            bet.winningAmount
        );
    }

    function getUserBets(address user) public view returns (BetInfo[] memory) {
        uint256 userBetCount = 0;
        for (uint256 i = 0; i < bets.length; i++) {
            if (bets[i].userAddress == user) {
                userBetCount++;
            }
        }

        BetInfo[] memory userBets = new BetInfo[](userBetCount);
        uint256 j = 0;

        for (uint256 i = 0; i < bets.length; i++) {
            if (bets[i].userAddress == user) {
                userBets[j] = bets[i];
                j++;
            }
        }

        return userBets;
    }

    


    function getPrice(string memory symbol)public view returns(int256){
        return priceFeed.getLatestPrice(symbol);
    }

function distributeFunds(address assetAddress) public {

         (
            ,
            string memory symbol,
            ,
            ,
            ,
            ,
        ) = assetManager.getAssetDetails(assetAddress);

        int256 subtractValue = getPrice(symbol);

        uint256 totalAssetBalance = assetBalances[assetAddress];
        require(totalAssetBalance > 0, "No funds to distribute for this asset");

        // Step 1: Create a list of estimates with the subtracted value
        BetInfo[] memory assetBets = getBetsForAsset(assetAddress);
        int256[] memory adjustedEstimates = new int256[](assetBets.length);

         if (assetBets.length == 1) {
        uint256 amount = totalAssetBalance; // Distribute entire balance
        address payable userAddress = payable(assetBets[0].userAddress);
        require(userAddress.send(amount), "Failed to transfer funds to better");
        emit FundsDistributed(assetAddress, userAddress, address(0), amount, 0, 0); // Set other payouts to 0
        totalBalance -= totalAssetBalance;
        return; // Exit the function after distributing to single better
    }

        for (uint256 i = 0; i < assetBets.length; i++) {
            adjustedEstimates[i] = int256(assetBets[i].estimate) - int256(subtractValue);
        }

        // Step 2: Calculate the magnitude (absolute value) of the estimates
        for (uint256 i = 0; i < adjustedEstimates.length; i++) {
            if (adjustedEstimates[i] < 0) {
                adjustedEstimates[i] = -adjustedEstimates[i];
            }
        }

        // Step 3: Sort the estimates in ascending order and get original indices
        uint256[] memory sortedIndices = sortIndicesByAdjustedEstimates(adjustedEstimates);

        // Step 4: Distribute funds
        uint256 amount1 = totalAssetBalance * 50 / 100;
        uint256 amount2 = totalAssetBalance * 20 / 100;

        assetBalances[assetAddress] = 0;

        if (amount1 > 0) {
            require(payable(assetBets[sortedIndices[0]].userAddress).send(amount1), "Failed to transfer funds to first place");
        }

        if (amount2 > 0) {
            require(payable(assetBets[sortedIndices[1]].userAddress).send(amount2), "Failed to transfer funds to second place");
        }

        (
            ,
            ,
            ,
            ,
            ,
            ,
            address betSetter
        ) = assetManager.getAssetDetails(assetAddress);
        require(betSetter != address(0), "Invalid bet setter address");

        uint256 amount3 = totalAssetBalance - amount1 - amount2;
        if (amount3 > 0) {
            require(payable(betSetter).send(amount3), "Failed to transfer funds to betSetter");
        }

        emit FundsDistributed(assetAddress, assetBets[sortedIndices[0]].userAddress, assetBets[sortedIndices[1]].userAddress, amount1, amount2, amount3);

        totalBalance -= totalAssetBalance;
    }

    // Helper function to get all bets for a specific asset
    function getBetsForAsset(address assetAddress) internal view returns (BetInfo[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < bets.length; i++) {
            if (bets[i].assetAddress == assetAddress) {
                count++;
            }
        }

        BetInfo[] memory assetBets = new BetInfo[](count);
        uint256 j = 0;
        for (uint256 i = 0; i < bets.length; i++) {
            if (bets[i].assetAddress == assetAddress) {
                assetBets[j] = bets[i];
                j++;
            }
        }
        return assetBets;
    }

    // Helper function to sort indices by adjusted estimates
    function sortIndicesByAdjustedEstimates(int256[] memory adjustedEstimates) internal pure returns (uint256[] memory) {
        uint256 length = adjustedEstimates.length;
        uint256[] memory indices = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            indices[i] = i;
        }

        for (uint256 i = 0; i < length; i++) {
            for (uint256 j = 0; j < length - 1; j++) {
                if (adjustedEstimates[indices[j]] > adjustedEstimates[indices[j + 1]]) {
                    uint256 temp = indices[j];
                    indices[j] = indices[j + 1];
                    indices[j + 1] = temp;
                }
            }
        }
        return indices;
    }

    function betsLength() public view returns (uint256) {
        return bets.length;
    }

    function updateWinningAmount(uint256 index, uint256 winningAmount) public {
        require(index < bets.length, "Bet index out of bounds");
        BetInfo storage bet = bets[index];
        require(bet.userAddress == msg.sender, "Not authorized to update this bet");

        bet.winningAmount = winningAmount;
    }
}
