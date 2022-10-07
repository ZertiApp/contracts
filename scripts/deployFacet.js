const hre = require("hardhat");
const spawn = require("child_process").spawn;
const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')

async function deployFacet () {
    const diamondAddress = "0x667855326c5cb7C9Edaf897bC3f14E552fD84955"
    const diamondCutFacet = await ethers.getContractAt("DiamondCutFacet", diamondAddress);

    const facetName = "SubscriptionFacet"
    const Facet = await ethers.getContractFactory(facetName);
    const facet = await Facet.deploy();
    await facet.deployed();
    const selectors = getSelectors(facet);
    console.log(facetName, 'deployed to:', facet.address);

    const pythonProcess = spawn('python',["scripts/verifyContracts.py", facet.address]);
    pythonProcess.stdout.on('data', (data) => {
        console.log(data.toString());
    });

    tx = await diamondCutFacet.diamondCut(
        [{
          facetAddress: facet.address,
          action: FacetCutAction.Add,
          functionSelectors: selectors
        }],
        ethers.constants.AddressZero, '0x', { gasLimit: 800000 })

    receipt = await tx.wait()
    if (!receipt.status) {
        throw Error(`Error:: ${facetName} deployment failed`)
    }
    console.log(facetName, 'deployed')
    console.log("tx hash:", tx.hash)





}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
    deployFacet()
      .then(() => process.exit(0))
      .catch(error => {
        console.error(error)
        process.exit(1)
      })
  }

  exports.deployFacet = deployFacet