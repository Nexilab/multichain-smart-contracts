const { ethers, upgrades } = require("hardhat");
const hre = require("hardhat");

async function deployWETH() {
    const WrappedETH = await ethers.getContractFactory("WETH");
    console.log("Deploying WETH...");
    const contract = await WrappedETH.deploy();
    await contract.deployed();
    console.log("WETH deployed to:", contract.address);
}
deployWETH()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
