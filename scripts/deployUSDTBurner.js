const { ethers, upgrades } = require("hardhat");
const hre = require("hardhat");

async function deployUSDTBurner() {
    const USDTBurner = await ethers.getContractFactory("USDTBurner");
    const usdtAddress = "0xA60e7e82560165a150F05e75F59bb8499D76AE12";
    console.log("Deploying USDTBurner...");
    const contract = await USDTBurner.deploy(usdtAddress);
    await contract.deployed();
    console.log("USDTBurner deployed to:", contract.address);
}
deployUSDTBurner()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
