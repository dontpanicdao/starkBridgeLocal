const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account: ", deployer.address);
    console.log("Account Balance: ", (await deployer.getBalance()).toString());

    const FactCheck = await ethers.getContractFactory("FactCheck");
    const fact = await FactCheck.deploy("0xde29d060D45901Fb19ED6C6e959EB22d8626708e");

    console.log("Fact Check is deployed to: ", fact.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    })