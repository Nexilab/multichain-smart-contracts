const { ethers, upgrades } = require("hardhat");
const hre = require("hardhat");

async function deployWUSDC() {
    const WrappedUSDC = await ethers.getContractFactory("WUSDC");
    console.log("Deploying WUSDC...");
    //const options = {
   //   gasLimit: 20000000, // افزایش محدوده gas
   // }
    //const contract = await WrappedUSDT.deploy(options);
    const contract = await WrappedUSDC.deploy();
    await contract.deployed();
    console.log("WUSDC deployed to:", contract.address);
}
deployWUSDC()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
