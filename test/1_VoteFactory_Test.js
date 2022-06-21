const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Cloning test", function () {
  let _votingCost = 5;
  const _minVotes = 50;
  const _timeToVote = 6;
  it("Should change Vote Implementation address", async function () {
    const VoteFactory = await hre.ethers.getContractFactory("VoteFactory");
    const vf = await VoteFactory.deploy();
    const Vote = await hre.ethers.getContractFactory("Vote");
    const vote = await Vote.deploy();

    var changeImplTx = await vf.changeImpl(vote.address);
    await changeImplTx.wait();

    expect(await vf.getImplAddr()).to.equal(vote.address);

    const vote2 = await Vote.deploy();
    var changeImplTx = await vf.changeImpl(vote2.address);
    await changeImplTx.wait();

    // wait until the transaction is mined
    expect(await vf.getImplAddr()).to.equal(vote2.address);

    /* console.log("       Vote1 address: " + vote.address);
    console.log("       Vote2 address: " + vote2.address); */
    
  });
  
  it("Should clone and initialize Vote contract", async function () {
    const VoteFactory = await hre.ethers.getContractFactory("VoteFactory");
    const vf = await VoteFactory.deploy();
    const Vote = await hre.ethers.getContractFactory("Vote");
    const vote = await Vote.deploy();

    const changeImplTx = await vf.changeImpl(vote.address);
    await changeImplTx.wait();

    const createVoteTx = await vf.createVote(_votingCost,_minVotes,_timeToVote);
    const receipt = await createVoteTx.wait();
    let proxyAddress;
    for (const event of receipt.events) {
      proxyAddress = event.args;
    }
    proxyAddress = proxyAddress[0];
    const voteProxy = await hre.ethers.getContractAt("Vote", proxyAddress);   
    
    expect(await voteProxy.getInit()).to.equal(true);

  });

  it("Should initialize variables correctly", async function () {
    const VoteFactory = await hre.ethers.getContractFactory("VoteFactory");
    const vf = await VoteFactory.deploy();
    const Vote = await hre.ethers.getContractFactory("Vote");
    const vote = await Vote.deploy();

    const changeImplTx = await vf.changeImpl(vote.address);
    await changeImplTx.wait();

    const createVoteTx = await vf.createVote(_votingCost,_minVotes,_timeToVote);
    let ms = Date.now();
    const receipt = await createVoteTx.wait();
    let proxyAddress;
    for (const event of receipt.events) {
      proxyAddress = event.args;
    }
    proxyAddress = proxyAddress[0];
    const voteProxy = await hre.ethers.getContractAt("Vote", proxyAddress);   

    const endDate = new Date(parseInt(await voteProxy.getEndTime())* 1000);
    const ExpectedEndDate = new Date(ms+6*24*60*60 * 1000);
    expect(endDate.getDate()).to.equal(ExpectedEndDate.getDate());
    _votingCost = (_votingCost.toString() + ".0")
    expect(await voteProxy.getVotingCost()).to.equal(ethers.utils.parseEther(_votingCost));
  });
});
