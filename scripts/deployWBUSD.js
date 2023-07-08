const { ethers, upgrades } = require("hardhat");
const hre = require("hardhat");

async function deployWBUSD() {
    const WrappedBUSD = await ethers.getContractFactory("WBUSD");
    console.log("Deploying WBUSD...");
    //const options = {
   //   gasLimit: 20000000, // افزایش محدوده gas
   // }
    //const contract = await WrappedUSDT.deploy(options);
    const contract = await WrappedBUSD.deploy();
    await contract.deployed();
    console.log("WBUSD deployed to:", contract.address);
}
deployWBUSD()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
