async function main() {
    const [deployer] = await ethers.getSigners();
  
    const Bet = await ethers.getContractFactory("Bet");
    const bet = await Bet.deploy("0x19260f944312E654BC72442f80635AAf46887Ae4", "0x9392Ab2205e584c032ebf3c693baCdCDCebb6204");
    await bet.deployed();
  
    console.log("Bet deployed to:", bet.address);
  
    return bet.address;
  }
  
  main()
    .then(address => {
      console.log(`Bet address: ${address}`);
      process.exit(0);
    })
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  
  
    // 0xd71DB4e92850F57ab51b45FD53c9471546fA9805