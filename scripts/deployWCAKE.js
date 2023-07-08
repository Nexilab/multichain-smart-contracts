const { ethers, upgrades } = require("hardhat");
const hre = require("hardhat");

async function deployWCAKE() {
    const WrappedWCAKE = await ethers.getContractFactory("WCAKE");
    console.log("Deploying WCAKE...");
    const contract = await WrappedWCAKE.deploy();
    await contract.deployed();
    console.log("WCAKE deployed to:", contract.address);
}
deployWCAKE()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
