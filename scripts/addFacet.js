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
    const ERC5516FacetAddress = "0x55CdcADC6E819b4907a50A59DCC706b88ce31E49"

    const diamondCutFacet = await ethers.getContractAt('DiamondCutFacet', diamondAddress)
    const diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)

    const ERC5516Facet  = await ethers.getContractAt('ERC5516Facet', ERC5516FacetAddress)

    const selectors = getSelectors(ERC5516Facet).remove(['supportsInterface(bytes4)'])

    let signWallet = new ethers.Wallet(ENV["TEST_ACCOUNT_PK"], ethers.provider);
    
    tx = await diamondCutFacet.connect(signWallet).diamondCut(
    [{
        facetAddress: ERC5516FacetAddress,
        action: FacetCutAction.Add,
        functionSelectors: selectors
    }],
    ethers.constants.AddressZero, '0x', { gasLimit: 30000000 })
    receipt = await tx.wait()
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`)
    }
    result = await diamondLoupeFacet.facetFunctionSelectors(ERC5516FacetAddress)
    //assert.sameMembers(result, selectors)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
