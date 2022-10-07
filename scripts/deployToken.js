const hre = require("hardhat");

async function deployToken () {
    const ZETTOKEN = await ethers.getContractFactory('ZetToken')
    const ZetToken = await ZETTOKEN.deploy()
    await ZetToken.deployed()
    console.log('ZetToken deployed:', ZetToken.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
    deployToken()
      .then(() => process.exit(0))
      .catch(error => {
        console.error(error)
        process.exit(1)
      })
  }

  exports.deployToken = deployToken