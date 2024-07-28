async function main() {
  const [deployer] = await ethers.getSigners();

  const AssetManager = await ethers.getContractFactory("AssetManager");
  const assetManager = await AssetManager.deploy();
  await assetManager.deployed();

  console.log("AssetManager deployed to:", assetManager.address);

  return assetManager.address;
}

main()
  .then(address => {
    console.log(`AssetManager address: ${address}`);
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });


  // 0x19260f944312E654BC72442f80635AAf46887Ae4