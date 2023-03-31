const { ethers, upgrades } = require("hardhat");
const hre = require("hardhat");

async function deployWBNB() {
    const WrappedBNB = await ethers.getContractFactory("WBNB");
    const underlyingAddress = '0x970609bA2C160a1b491b90867681918BDc9773aF'; // Token address in BSC
    const name = 'Wrapped USDT';
    const symbol = 'wUSDT';
    const decimals = 18;
    const totalSupply = ethers.utils.parseUnits('10', decimals); // initial supply of 1,000,000,000 wUSDT
    const totalSupplyStr = "1000000000000000000"; // initial supply of 1,000,000,000 wUSDT
    const cap = ethers.utils.parseUnits('10000000000', decimals); // cap of 10,000,000,000 wUSDT
    const capStr = "1000000000000000000000000000";
    const adminAddress = "0x9029660f74eC130CEdb90B42F4524BB2799A20A2";
    console.log("Deploying WBNB...");
    const contract = await WrappedBNB.deploy();
    await contract.deployed();
    console.log("WBNB deployed to:", contract.address);
    await hre.run("verify:verify", {
        address: contract.address,
        constructorArguments: [],
        network: "Nexi",
      });
}
deployWBNB()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
