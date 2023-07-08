const { ethers, upgrades } = require("hardhat");
const hre = require("hardhat");

async function deployPowerPayToken() {
    const PowerPayToken = await ethers.getContractFactory("PowerPayToken");
    console.log("Deploying PowerPayToken...");
    const options = {
      gasLimit: 20000000, // افزایش محدوده gas
    }
    //const contract = await WrappedUSDT.deploy(options);
    const adminAccount = "0x183A3dFadd2D9c702C71b021Db87fe6C34F2b387";
    const contract = await PowerPayToken.deploy();
    await contract.deployed();
    console.log("PowerPayToken deployed to:", contract.address);
    const amountInEther = "10000000000";
    const amountInWei = ethers.utils.parseEther(amountInEther);
    const maxMintInEther = "500000000000";
    const maxMintInWei = ethers.utils.parseEther(maxMintInEther);
    await contract.addMinter(adminAccount,maxMintInWei,maxMintInWei);
    console.log("add Minter %s to PowerPayToken", adminAccount );
    await contract.addFreezer(adminAccount);
    console.log("add Freezer %s to USDT", adminAccount );
    await contract.mint(adminAccount,amountInWei);
    console.log("%s token minted to acount %s PowerPayToken", amountInEther,adminAccount );
}
deployPowerPayToken()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
