# DecentralizedDen_SmartContracts

## Problem Statement
In today’s investment landscape, analyzing stock and cryptocurrency price trends is crucial but often complex. To address this, we propose a decentralized application (DApp) that gamifies cryptocurrency price predictions. Users will invest Ethereum (ETH) based on their forecasts of future cryptocurrency prices. Accurate predictions will earn users rewards exceeding their initial investment. This platform combines the excitement of gaming with crypto markets, offering an engaging way to test prediction skills and earn rewards. Our goals are to provide an engaging experience, reward accuracy, ensure transparency, and create an intuitive user interface.

# Contract Explanation

## Asset.sol
### In this, all the properties of asset are stored like  name, closing time etc.
- It does not invokes itself.
- Asset Manager invokes this.
- It makes  unique address of each asset.

## AssetManager.sol
### Here all predictions are made live.
- User sets opening time, closing time, betPrice etc.
- It invokes Asset.sol to get a unique  address. 
- The person who set this get 25% of  the total  reward.

## Bet.sol
#### It is the place where all users predict prices.
- Connect MetaMask Wallet
- Predict the price whose predictions.
- Predictions are checked by PriceFeed.sol which give us price  of  that cryptoCurrency.

