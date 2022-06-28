const { expect } = require("chai");
const { ethers } = require("hardhat");

function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

describe("Badge.sol", function () { 
    let deployer, addr1, addr2, badge, addrs
    beforeEach(async function () {
        //Get contract factories
        const Badge = await ethers.getContractFactory("EIPARAZI");

        //Get signers
        [deployer, addr1, addr2, ...addrs] = await ethers.getSigners();
        //Deploy contrats
        badge = await Badge.deploy();
    })
    describe("Mint zerties", async function () {
        it("SHould mint tokens", async function (){
            await expect(badge.mint("ILUKIW"))
        .to.emit(badge, "ZertiMinted")
        .withArgs(
            owner.address,
            1,
        )
        await expect(badge.mint("watafak"))
        .to.emit(badge, "ZertiMinted")
        .withArgs(
            owner.address,
            2,
        )
        await expect(badge.mint("grays anatomy"))
        .to.emit(badge, "ZertiMinted")
        .withArgs(
            owner.address,
            3,
        )
        })
        
        it("Testing idInfo()", async function(){
            
        })
    })
})
