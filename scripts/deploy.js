const hre = require("hardhat");

async function main() {
  const VoteFactory = await hre.ethers.getContractFactory("VoteFactory");
  const vf = await VoteFactory.deploy();
  const Vote= await hre.ethers.getContractFactory("Vote");
  const vote = await Vote.deploy();

  await vf.deployed();
  await vote.deployed();

  console.log("Vote Factory deployed to:", vf.address);
  console.log("Vote deployed to:", vote.address);

  vf.changeImpl(vote.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
