const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Vote test", function () {
  const _votingCost = 5;
  const _minVotes = 50;
  const _timeToVote = 2;
  it("Should receive votes", async function () {
    const [owner, addr1, addr2, addr3] = await ethers.getSigners();

    const VoteFactory = await hre.ethers.getContractFactory("VoteFactory");
    const vf = await VoteFactory.deploy();
    const Vote = await hre.ethers.getContractFactory("Vote");
    const vote = await Vote.deploy();

    const changeImplTx = await vf.changeImpl(vote.address);
    await changeImplTx.wait();

    const createVoteTx = await vf.createVote(
      _votingCost,
      _minVotes,
      _timeToVote
    );
    const receipt = await createVoteTx.wait();

    let proxyAddress;
    for (const event of receipt.events) {
      proxyAddress = event.args;
    }
    proxyAddress = proxyAddress[0];

    const voteProxy = await hre.ethers.getContractAt("Vote", proxyAddress);

    let nVotes = 0;
    let votesAgainst = 0;
    let votesInFavour = 0;
    const options = {
      value: ethers.utils.parseEther(_votingCost.toString() + ".0"),
    };

    let voteTx = await voteProxy.sendVote(0, options);
    await voteTx.wait();
    votesAgainst++;
    nVotes++;

    voteTx = await voteProxy.connect(addr1).sendVote(0, options);
    await voteTx.wait();
    votesAgainst++;
    nVotes++;

    voteTx = await voteProxy.connect(addr2).sendVote(0, options);
    await voteTx.wait();
    votesAgainst++;
    nVotes++;

    voteTx = await voteProxy.connect(addr3).sendVote(1, options);
    await voteTx.wait();
    votesInFavour++;
    nVotes++;

    expect(await voteProxy.getVotesAgainst()).to.equal(votesAgainst);
    expect(await voteProxy.getVotesInFavour()).to.equal(votesInFavour);
    expect(await voteProxy.getUserVoted(owner.address)).to.equal(true);
    expect(await voteProxy.getUserVoted(addr1.address)).to.equal(true);
    expect(await voteProxy.getUserVoted(addr2.address)).to.equal(true);
    expect(await voteProxy.getUserVoted(addr3.address)).to.equal(true);
    expect(await voteProxy.getTotalDeposit()).to.equal(
      ethers.utils.parseEther((_votingCost * nVotes).toString() + ".0")
    );
  });
});
