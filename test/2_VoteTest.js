const { expect } = require("chai");
const { ethers } = require("hardhat");

function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

describe("Vote.sol", function () {
  const _votingCost = 3;
  const _minVotes = 3;
  const _timeToVote = 2;
  it("Should receive votes correctly", async function () {
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

    let _nVotes = 0;
    let _votesAgainst = 0;
    let _votesInFavour = 0;

    const options = {
      value: ethers.utils.parseEther(_votingCost.toString() + ".0"), 
    };

    let voteTx = await voteProxy.sendVote(0, options);
    await voteTx.wait();
    _votesAgainst++;
    _nVotes++;

    voteTx = await voteProxy.connect(addr1).sendVote(0, options);
    await voteTx.wait();
    _votesAgainst++;
    _nVotes++;

    voteTx = await voteProxy.connect(addr2).sendVote(0, options);
    await voteTx.wait();
    _votesAgainst++;
    _nVotes++;

    voteTx = await voteProxy.connect(addr3).sendVote(1, options);
    await voteTx.wait();
    _votesInFavour++;
    _nVotes++;

    await delay(500);
    expect(await voteProxy.getVotesAgainst()).to.equal(_votesAgainst);
    expect(await voteProxy.getVotesInFavour()).to.equal(_votesInFavour);
    expect(await voteProxy.getUserVoted(owner.address)).to.equal(true);
    expect(await voteProxy.getUserVoted(addr1.address)).to.equal(true);
    expect(await voteProxy.getUserVoted(addr2.address)).to.equal(true);
    expect(await voteProxy.getUserVoted(addr3.address)).to.equal(true);
    expect(await voteProxy.getTotalDeposit()).to.equal(
      ethers.utils.parseEther((_votingCost * _nVotes).toString() + ".0")
    );

  });

  it ("Should distribute pool correctly" , async function () {

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

    const options = {
      value: ethers.utils.parseEther(_votingCost.toString() + ".0"),
    };

    let voteTx = await voteProxy.sendVote(0, options);
    await voteTx.wait();

    voteTx = await voteProxy.connect(addr1).sendVote(0, options);
    await voteTx.wait();

    voteTx = await voteProxy.connect(addr2).sendVote(0, options);
    await voteTx.wait();

    voteTx = await voteProxy.connect(addr3).sendVote(1, options);
    await voteTx.wait();

    const voteFinalizationTx = await voteProxy.connect(owner).voteFinalization();
    await voteFinalizationTx.wait();

    await delay(500);
    expect(await voteProxy.getTotalDeposit()).to.equal(
      ethers.utils.parseEther("0.0")  //FIX DIVISION ERROR, SOLIDITY DOES NOT SUPPORT FLOATING POINT
    );

  });
});
