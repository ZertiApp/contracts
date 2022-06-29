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
        it("Should mint tokens", async function (){
            await expect(badge.mint('ILUKIW'))
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
        
        it("Info of zerties ", async function(){
            expect( await badge.uriOf(1)).to.equal('ILUKIW')
            expect( await badge.uriOf(2)).to.equal("watafak")
            expect( await badge.uriOf(3)).to.equal("grays anatomy")

            expect(await badge.amountOf(1)).to.equal(0)
            expect(await badge.amountOf(2)).to.equal(0)
            expect(await badge.amountOf(3)).to.equal(0)
        })
    })
})
