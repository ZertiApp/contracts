const Vote = artifacts.require('Vote');
const VoteFactory = artifacts.require('VoteFactory');

module.exports = async function(deployer) {
   deployer.deploy(Vote).then(() => {
     return deployer.deploy(VoteFactory, Vote.address);
   })
};