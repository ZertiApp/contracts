const { expect } = require("chai");
const { ethers } = require("hardhat");

function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

describe("VoteFactory.sol", function () {
  let _votingCost = 5;
  const _minVotes = 50;
  const _timeToVote = 6;
  it("Should change Vote implementation address", async function () {
    const VoteFactory = await hre.ethers.getContractFactory("VoteFactory");
    const vf = await VoteFactory.deploy();
    const Vote = await hre.ethers.getContractFactory("Vote");
    const vote = await Vote.deploy();

    var changeImplTx = await vf.changeImpl(vote.address);
    await changeImplTx.wait();

    await delay(1000);
    expect(await vf.getImplAddr()).to.equal(vote.address); 

    const vote2 = await Vote.deploy();
    var changeImplTx = await vf.changeImpl(vote2.address);
    await changeImplTx.wait();

    await delay(1000);
    expect(await vf.getImplAddr()).to.equal(vote2.address); 

    /* console.log("       Vote1 address: " + vote.address);
    console.log("       Vote2 address: " + vote2.address); */
    
  });
  describe("Initialization", function () {
    it("Should clone and initialize Vote contracts", async function () {
      const VoteFactory = await hre.ethers.getContractFactory("VoteFactory");
      const vf = await VoteFactory.deploy();
      const Vote = await hre.ethers.getContractFactory("Vote");
      const vote = await Vote.deploy();

      const changeImplTx = await vf.changeImpl(vote.address);
      await changeImplTx.wait();

      let createVoteTx = await vf.createVote(_votingCost,_minVotes,_timeToVote);
      let receipt = await createVoteTx.wait();
      let proxyAddress;
      for (const event of receipt.events) {
        proxyAddress = event.args;
      }
      proxyAddress = proxyAddress[0];
      const voteProxy = await hre.ethers.getContractAt("Vote", proxyAddress);   
    
      createVoteTx = await vf.createVote(_votingCost,_minVotes,_timeToVote);
      receipt = await createVoteTx.wait();
      proxyAddress;
      for (const event of receipt.events) {
        proxyAddress = event.args;
      }
      proxyAddress = proxyAddress[0];
      const voteProxy2 = await hre.ethers.getContractAt("Vote", proxyAddress);   

      await delay(2000);
      expect(await voteProxy.getInit()).to.equal(true);
      expect(await voteProxy2.getInit()).to.equal(true);
      expect(voteProxy.address).to.not.equal(voteProxy2.address); 
    });

    it("Should initialize variables correctly", async function () {
      const sender = await ethers.getSigner();

      const VoteFactory = await hre.ethers.getContractFactory("VoteFactory");
      const vf = await VoteFactory.deploy();
      const Vote = await hre.ethers.getContractFactory("Vote");
      const vote = await Vote.deploy();

      const changeImplTx = await vf.changeImpl(vote.address);
      await changeImplTx.wait();

      const createVoteTx = await vf.createVote(_votingCost,_minVotes,_timeToVote);
      let msNow = Date.now();
      const receipt = await createVoteTx.wait();
      let proxyAddress;
      for (const event of receipt.events) {
        proxyAddress = event.args;
      }
      proxyAddress = proxyAddress[0];
      const voteProxy = await hre.ethers.getContractAt("Vote", proxyAddress);   

      const _endDate = new Date(parseInt(await voteProxy.getEndTime())*1000); //Only check date, given that seconds will be different because of transaction await
      const _expectedEndDate = new Date(msNow +_timeToVote*24*60*60*1000); //ms Expected time = _timeToVote days * 24 h * 60 m * 60 s * 1 ms

      await delay(2000);
      expect(_endDate.getDate()).to.equal(_expectedEndDate.getDate());
      _votingCost = (_votingCost.toString() + ".0");
      expect(await voteProxy.getVotingCost()).to.equal(ethers.utils.parseEther(_votingCost));
      expect(await voteProxy.getWhoBeingVoted()).to.equal(sender.address);
    });
  });
});