const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Vote test", function () {
    it("Should receive votes", async function () {
        const [owner, addr1, addr2, addr3] = await ethers.getSigners();

        const VoteFactory = await hre.ethers.getContractFactory("VoteFactory");
        const vf = await VoteFactory.deploy();
        const Vote = await hre.ethers.getContractFactory("Vote");
        const vote = await Vote.deploy();

        const initTx = await vote.initialize(10 , 2, 1000,owner.address);
        await initTx.wait();

        let voteTx = await vote.receiveVote(0, {value: ethers.utils.parseEther("10.0")});
        await voteTx.wait();
        voteTx = await  vote.connect(addr1).receiveVote(0, {value: ethers.utils.parseEther("10.0")}); 
        await voteTx.wait();
        voteTx = await  vote.connect(addr2).receiveVote(0, {value: ethers.utils.parseEther("10.0")});
        await voteTx.wait();
        voteTx = await  vote.connect(addr3).receiveVote(1, {value: ethers.utils.parseEther("10.0")});
        await voteTx.wait();

        expect(await vf.getVotesAgainst()).to.equal(3);
        expect(await vf.getVotesInFavour()).to.equal(1);
      });
});