const { ethers, upgrades } = require("hardhat");

async function main(){
    console.log("Deploying LamborghiniToken...");
    const LamborghiniToken = await ethers.getContractFactory("LamborghiniToken");
    //const contract = await upgrades.deployProxy(CashUSDToken,["CashUSDToken"],{kind:'uups',initializer:'initialize'});
    //const contract = await upgrades.deployProxy(CashUSDToken, ["CashUSDToken"], { kind: 'uups', initializer: 'initialize' });
    const lamborghiniToken = await upgrades.deployProxy(LamborghiniToken, { kind: 'uups', initializer: 'initialize' });

    await lamborghiniToken.deployed();
    console.log("Lamborghini Proxy contract deployed at : ",lamborghiniToken.address);
    console.log("Lamborghini Implementation contract deployed at : ",await upgrades.erc1967.getImplementationAddress(lamborghiniToken.address));
}

main()
.then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
