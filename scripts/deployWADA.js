const { ethers, upgrades } = require("hardhat");
const hre = require("hardhat");

async function deployADA() {
    const WrappedADA = await ethers.getContractFactory("WADA");
    console.log("Deploying WADA...");
    //const options = {
   //   gasLimit: 20000000, // افزایش محدوده gas
   // }
    //const contract = await WrappedDOGE.deploy(options);
    const contract = await WrappedADA.deploy();
    await contract.deployed();
    console.log("WADA deployed to:", contract.address);
}
deployADA()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
