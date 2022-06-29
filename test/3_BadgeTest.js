const { expect } = require("chai");
const { ethers } = require("hardhat");

function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

describe("Badge.sol", function () {
    let owner, addr1, addr2, badge, addrs
    beforeEach(async function () {
        //Get contract factories
        const Badge = await ethers.getContractFactory("EIPARAZI");

        //Get signers
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
        //Deploy contrats
        badge = await Badge.deploy();
    });
    describe("Minting", async function () {
        it("Should mint tokens", async function () {
            await expect(badge.mint('ILUKIW'))
                .to.emit(badge, "ZertiMinted")
                .withArgs(
                    owner.address,
                    1,
                );
            await expect(badge.mint("watafak"))
                .to.emit(badge, "ZertiMinted")
                .withArgs(
                    owner.address,
                    2,
                );
            await expect(badge.mint("grays-anatomy"))
                .to.emit(badge, "ZertiMinted")
                .withArgs(
                    owner.address,
                    3,
                )
        });

        it("Should init info correctly ", async function () {
            const uris = ['ILUKIW', 'watafak', "grays-anatomy"];
            for(let i = 0; i<uris.length; i++){
                let mintTx = await badge.mint(uris[i]);
                await mintTx.wait();
            }

            for(let i = 0; i<uris.length; i++){
                expect(await badge.uriOf(i+1)).to.equal(uris[i]);
                expect(await badge.amountOf(i+1)).to.equal(0);
                expect(await badge.ownerOf(i+1)).to.equal(owner);
            }
        })
    })
})
