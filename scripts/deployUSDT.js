const { ethers, upgrades } = require("hardhat");
const hre = require("hardhat");

async function deployUSDT() {
    const WrappedUSDT = await ethers.getContractFactory("USDT");
    console.log("Deploying USDT...");
    //const options = {
   //   gasLimit: 20000000, // افزایش محدوده gas
   // }
    //const contract = await WrappedUSDT.deploy(options);
    const adminAccount = "0x4DA7D707F363A3Dd372b2e91e721168bafe77062";
    const contract = await WrappedUSDT.deploy();
    await contract.deployed();
    console.log("USDT deployed to:", contract.address);
    //const amountInEther = "200000000.0"; // مقدار Ether که می‌خواهید به واحد Wei تبدیل شود را وارد کنید
   // const amountInWei = ethers.utils.parseEther(amountInEther);
    //const maxMintInEther = "500000000000.0"; // مقدار Ether که می‌خواهید به واحد Wei تبدیل شود را وارد کنید
    //const maxMintInWei = ethers.utils.parseEther(maxMintInEther);
    //await contract.addMinter(adminAccount,maxMintInWei,maxMintInWei);
    //console.log("add Minter %s to USDT", adminAccount );
    //await contract.addFreezer(adminAccount);
    //console.log("add Freezer %s to USDT", adminAccount );
   // await contract.mint(adminAccount,amountInWei);
   // console.log("%s token minted to acount %s USDT", amountInEther,adminAccount );
}
deployUSDT()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
