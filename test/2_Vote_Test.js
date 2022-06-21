const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Vote test", function () {
  const _votingCost = 10;
  const _minVotes = 2;
  const _timeToVote = 2;
    it("Should receive votes (Vote noProxy)", async function () {
        const [owner, addr1, addr2, addr3] = await ethers.getSigners();

        const Vote = await hre.ethers.getContractFactory("Vote");
        const vote = await Vote.deploy();

        const initTx = await vote.initialize(_votingCost , _minVotes, _timeToVote, owner.address);
        await initTx.wait();

        const options = {value: ethers.utils.parseEther(_votingCost.toString()+".0")}

        let voteTx = await vote.sendVote(0,options);
        await voteTx.wait();
        voteTx = await  vote.connect(addr1).sendVote(0, options); 
        await voteTx.wait();
        voteTx = await  vote.connect(addr2).sendVote(0, options);
        await voteTx.wait();
        voteTx = await  vote.connect(addr3).sendVote(1, options);
        await voteTx.wait();

        expect(await vote.getVotesAgainst()).to.equal(3);
        expect(await vote.getVotesInFavour()).to.equal(1);
      });
});