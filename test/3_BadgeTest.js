const { expect } = require("chai");
const { ethers } = require("hardhat");

function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

describe("Badge.sol", function () { 
    it("Should mint tokens", async function () {
        const [owner, addr1, addr2, addr3] = await ethers.getSigners();

        const Badge = await hre.ethers.getContractFactory("EIPARAZI");
        const badge = await Badge.deploy();

        const mintTx = await badge.mint("ILUKIW");
        await mintTx.wait();

        expect(await badge.idInfo(0)).to.equal(owner.address, "ILUKIW", 0);  
    });
});
