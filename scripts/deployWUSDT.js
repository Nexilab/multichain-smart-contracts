const { ethers, upgrades } = require("hardhat");
const hre = require("hardhat");

async function deployWUSDT() {
    const WrappedUSDT = await ethers.getContractFactory("WUSDT");
    console.log("Deploying WUSDT...");
    //const options = {
   //   gasLimit: 20000000, // افزایش محدوده gas
   // }
    //const contract = await WrappedUSDT.deploy(options);
    const contract = await WrappedUSDT.deploy();
    await contract.deployed();
    console.log("WUSDT deployed to:", contract.address);
}
deployWUSDT()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
