const {
    getSelectors,
    FacetCutAction,
    removeSelectors,
    findAddressPositionInFacets
  } = require('../scripts/libraries/diamond.js')

const { ENV } = require("../config");

const hre = require("hardhat");
const { assert } = require('chai')

async function main() {
    const diamondAddress = "0x667855326c5cb7C9Edaf897bC3f14E552fD84955"

    const diamondCutFacet = await ethers.getContractAt('DiamondCutFacet', diamondAddress)
    const diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)

    FacetName = "AddSupportedInterfacesFacet"
    const Facet = await ethers.getContractFactory(FacetName)
    const facet = await Facet.deploy()
    await facet.deployed()

    const facetAddress = facet.address
    console.log("Deployed facet:", facetAddress)
    console.log("Deploy transaction hash:", facet.deployTransaction.hash) 

    const selectors = getSelectors(facet)

    let signWallet = new ethers.Wallet(ENV["TEST_ACCOUNT_PK"], ethers.provider);
    
    tx = await diamondCutFacet.connect(signWallet).diamondCut(
    [{
        facetAddress: facetAddress,
        action: FacetCutAction.Add,
        functionSelectors: selectors
    }],
    ethers.constants.AddressZero, '0x', { gasLimit: 30000000, gasPrice: 1000})
    receipt = await tx.wait()
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`)
    } else {
        console.log("Diamond upgrade successful:", tx.hash)
    }
    result = await diamondLoupeFacet.facetFunctionSelectors(facetAddress)
    assert.sameMembers(result, selectors)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
