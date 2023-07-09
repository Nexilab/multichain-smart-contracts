const { ethers, upgrades } = require("hardhat");

async function main(){
    console.log("Deploying CashUSDToken...");
    const CashUSDToken = await ethers.getContractFactory("CashUSDToken");
    //const contract = await upgrades.deployProxy(CashUSDToken,["CashUSDToken"],{kind:'uups',initializer:'initialize'});
    //const contract = await upgrades.deployProxy(CashUSDToken, ["CashUSDToken"], { kind: 'uups', initializer: 'initialize' });
    const contract = await upgrades.deployProxy(CashUSDToken, { kind: 'uups', initializer: 'initialize' });

    await contract.deployed();
    console.log("CashUSDToken Proxy contract deployed at : ",contract.address);
    console.log("CashUSDToken Implementation contract deployed at : ",await upgrades.erc1967.getImplementationAddress(contract.address));
}

main()
.then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
