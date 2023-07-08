const { ethers, upgrades } = require("hardhat");
const hre = require("hardhat");

async function deployWDOGE() {
    const WrappedDOGE = await ethers.getContractFactory("WDOGE");
    console.log("Deploying WDOGE...");
    //const options = {
   //   gasLimit: 20000000, // افزایش محدوده gas
   // }
    //const contract = await WrappedDOGE.deploy(options);
    const contract = await WrappedDOGE.deploy();
    await contract.deployed();
    console.log("WDOGE deployed to:", contract.address);
}
deployWDOGE()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
