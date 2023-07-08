const { ethers, upgrades } = require("hardhat");
const hre = require("hardhat");

async function deployWBTC() {
    const WrappedBTC = await ethers.getContractFactory("WBTC");
    console.log("Deploying WBTC...");
    const contract = await WrappedBTC.deploy();
    await contract.deployed();
    console.log("WBTC deployed to:", contract.address);
    await hre.run("verify:verify", {
        address: contract.address,
        constructorArguments: [],
        network: "Nexi",
      });
}
deployWBTC()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
