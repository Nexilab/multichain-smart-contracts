const { ethers, upgrades } = require("hardhat");
const hre = require("hardhat");

async function deployTestWrap() {
    const TestWrap = await ethers.getContractFactory("WBNB");
    const underlyingAddress = '0x970609bA2C160a1b491b90867681918BDc9773aF'; // Token address in BSC
    const name = 'Wrapped BNB';
    const symbol = 'WBNB';
    const decimals = 18;
    //const totalSupply = ethers.utils.parseUnits('10', decimals); // initial supply of 1,000,000,000 wUSDT
    //const totalSupplyStr = "1000000000000000000"; // initial supply of 1,000,000,000 wUSDT
    const cap = ethers.utils.parseUnits('10000000000', decimals); // cap of 10,000,000,000 wUSDT
    const capStr = "10000000000000000000000000000";
    const adminAddress = "0x06aD7D3FB4de5302f7659aB9455541D3c88786A2";
    console.log("Deploying TestWrap...");
    const contract = await TestWrap.deploy();
    await contract.deployed();
    console.log("TestWrap deployed to:", contract.address);
    await hre.run("verify:verify", {
        address: contract.address,
        constructorArguments: [],
        network: "Nexi",
      });
}
deployTestWrap()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
