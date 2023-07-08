const { ethers, upgrades } = require("hardhat");
const hre = require("hardhat");

async function deployWDAI() {
    const WrappedDAI = await ethers.getContractFactory("WDAI");
    console.log("Deploying WDAI...");
    //const options = {
   //   gasLimit: 20000000, // افزایش محدوده gas
   // }
    //const contract = await WrappedUSDT.deploy(options);
    const contract = await WrappedDAI.deploy();
    await contract.deployed();
    console.log("WDAI deployed to:", contract.address);
}
deployWDAI()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
