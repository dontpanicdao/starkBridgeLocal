const { expect } = require("chai");
const { ethers } = require("hardhat");

const abi = [
    "function isValid(bytes32 fact) external view returns(bool)",
    "function callProxyImplementation() external view returns(address)"
];

const L1CONN = process.env.L1CONN
const L2CONN = process.env.L2CONN

before(async () => {
    
})

describe("ShipFactCheckGoerli", function() {
    it("should propogate valid fact to L2 starknet", async function () {
        const FactCheck = await ethers.getContractFactory("FactCheck");
        const fact = await FactCheck.attach(L1CONN);

        const factStr = "0xe6168c0a865aa80d724ad05627fa65fbcfe4b1d66a586e9f348f461b076072c4";
        let fact_id = ethers.utils.arrayify(factStr);
        let bigAddr = ethers.BigNumber.from(L2CONN);
        
        const shipSharpStarkTX = await fact.shipSharpStark(bigAddr, fact_id);
        await shipSharpStarkTX.wait();

        console.log("TX HASH: ", shipSharpStarkTX.hash)
        expect(shipSharpStarkTX.hash).to.exist
    });
});

describe("ShipFakeFactCheckGoerli", function() {
    it("should fail on invalid fact to L2 starknet", async function () {
        const FactCheck = await ethers.getContractFactory("FactCheck");
        const fact = await FactCheck.attach(L1CONN);

        const factStr = "0xFFFFFc0a865aa80d724ad05627fa65fbcfe4b1d66a586e9f348f461b076072c4";
        let fact_id = ethers.utils.arrayify(factStr);
        let bigAddr = ethers.BigNumber.from(L2CONN);
        
        const shipSharpStarkTX = await fact.shipSharpStark(bigAddr, fact_id);
        await shipSharpStarkTX.wait();

        expect(shipSharpStarkTX.hash).to.not.exist
    });
});

describe("ProxyFactCheckGoerli", function() {
    it("should propogate valid fact to L2 starknet", async function () {
        const FactCheck = await ethers.getContractFactory("FactCheck");
        const fact = await FactCheck.attach(L1CONN);

        const factStr = "0xe6168c0a865aa80d724ad05627fa65fbcfe4b1d66a586e9f348f461b076072c4";
        let fact_id = ethers.utils.arrayify(factStr);

        const factValidity = await fact.proxyIsValid(fact_id);

        expect(factValidity).to.be.true
    });
});

describe("CallL1Sharp", function() {
    it("verify fact with sharp", async function () {
        let sharpVerifier = new ethers.Contract("0x5EF3C980Bf970FcE5BbC217835743ea9f0388f4F", abi, ethers.provider);
        let factStr = "0xe6168c0a865aa80d724ad05627fa65fbcfe4b1d66a586e9f348f461b076072c4";
        let factValidity = await sharpVerifier.isValid(factStr);

        expect(factValidity).to.be.true
    });
});

// describe("get starknet os", function() {
//     it("should fetch starknetos", async function() {
//         const FactCheck = await ethers.getContractFactory("FactCheck");
//         // const fact = await FactCheck.deploy("0xde29d060D45901Fb19ED6C6e959EB22d8626708e");
//         // console.log("ADDR: ", fact.address);
//         // await fact.deployed();

        // const fact = await FactCheck.deploy(L1CONN);
        // console.log("ADDR: ", fact.address);
        // await fact.deployed();

//         const fact = await FactCheck.attach("0x838a5F20faa0F096D0b7b635D9D6b6e44aDf269d");
//         const starkOS = await fact.getStarknetCore();
//         console.log("STARK OS: ", starkOS);
//     });
// });
