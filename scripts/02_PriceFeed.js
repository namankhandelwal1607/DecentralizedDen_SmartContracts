async function main() {
    const [deployer] = await ethers.getSigners();
  
    const PriceFeed = await ethers.getContractFactory("PriceFeed");
    const priceFeed = await PriceFeed.deploy();
    await priceFeed.deployed();
  
    console.log("PriceFeed deployed to:", priceFeed.address);
  
    return priceFeed.address;
  }
  
  main()
    .then(address => {
      console.log(`PriceFeed address: ${address}`);
      process.exit(0);
    })
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  
  
    //  0x9392Ab2205e584c032ebf3c693baCdCDCebb6204