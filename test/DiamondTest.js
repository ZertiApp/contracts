
//https://github.com/mudgen/diamond-1-hardhat/blob/main/test/diamondTest.js

const {
    getSelectors,
    FacetCutAction,
    removeSelectors,
    findAddressPositionInFacets
  } = require('../scripts/libraries/diamond.js')
  
  const { deployDiamond } = require('../scripts/deploy.js')
  
  const { assert } = require('chai')
  
  describe('DiamondTest', async function () {
    let diamondAddress
    let diamondCutFacet
    let diamondLoupeFacet
    let ownershipFacet
    let tx
    let receipt
    let result
    const addresses = []
  
    before(async function () {
      diamondAddress = await deployDiamond()
      diamondCutFacet = await ethers.getContractAt('DiamondCutFacet', diamondAddress)
      diamondLoupeFacet = await ethers.getContractAt('DiamondLoupeFacet', diamondAddress)
      ownershipFacet = await ethers.getContractAt('OwnershipFacet', diamondAddress)
    })
  
    it('should have three facets -- call to facetAddresses function', async () => {
      for (const address of await diamondLoupeFacet.facetAddresses()) {
        addresses.push(address)
      }
  
      assert.equal(addresses.length, 3)
    })
  
    it('facets should have the right function selectors -- call to facetFunctionSelectors function', async () => {
      let selectors = getSelectors(diamondCutFacet)
      result = await diamondLoupeFacet.facetFunctionSelectors(addresses[0])
      assert.sameMembers(result, selectors)
      selectors = getSelectors(diamondLoupeFacet)
      result = await diamondLoupeFacet.facetFunctionSelectors(addresses[1])
      assert.sameMembers(result, selectors)
      selectors = getSelectors(ownershipFacet)
      result = await diamondLoupeFacet.facetFunctionSelectors(addresses[2])
      assert.sameMembers(result, selectors)
    })
  
    it('selectors should be associated to facets correctly -- multiple calls to facetAddress function', async () => {
      assert.equal(
        addresses[0],
        await diamondLoupeFacet.facetAddress('0x1f931c1c')
      )
      assert.equal(
        addresses[1],
        await diamondLoupeFacet.facetAddress('0xcdffacc6')
      )
      assert.equal(
        addresses[1],
        await diamondLoupeFacet.facetAddress('0x01ffc9a7')
      )
      assert.equal(
        addresses[2],
        await diamondLoupeFacet.facetAddress('0xf2fde38b')
      )
    })
  
    it('should add ERC5516 functions', async () => {
      const ERC5516FACET = await ethers.getContractFactory('ERC5516Facet')
      const ERC5516Facet = await ERC5516FACET.deploy()
      await ERC5516Facet.deployed()
      addresses.push(ERC5516Facet.address)
      const selectors = getSelectors(ERC5516Facet).remove(['supportsInterface(bytes4)'])
      tx = await diamondCutFacet.diamondCut(
        [{
          facetAddress: ERC5516Facet.address,
          action: FacetCutAction.Add,
          functionSelectors: selectors
        }],
        ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
      receipt = await tx.wait()
      if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`)
      }
      result = await diamondLoupeFacet.facetFunctionSelectors(ERC5516Facet.address)
      assert.sameMembers(result, selectors)
    })
  
    it('should test function call', async () => {
      const ERC5516Facet = await ethers.getContractAt('ERC5516Facet', diamondAddress)
      assert.equal(await ERC5516Facet.contractUri(), "https://ipfs.io/ipfs/Qmbpy53C1k9XLYhz7UR5YvACYPS3FQEaZb4ffnAGmD2fQL");
    })

    it('should replace supportsInterface function', async () => {
      const ERC5516Facet = await ethers.getContractFactory('ERC5516Facet')
      const selectors = getSelectors(ERC5516Facet).get(['supportsInterface(bytes4)'])
      const ERC5516FacetAddress = addresses[3]
      tx = await diamondCutFacet.diamondCut(
        [{
          facetAddress: ERC5516FacetAddress,
          action: FacetCutAction.Replace,
          functionSelectors: selectors
        }],
        ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
      receipt = await tx.wait()
      if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`)
      }
      result = await diamondLoupeFacet.facetFunctionSelectors(ERC5516FacetAddress)
      assert.sameMembers(result, getSelectors(ERC5516Facet))
    })

    it('should add test2 functions', async () => {
      const Test2Facet = await ethers.getContractFactory('Test2Facet')
      const test2Facet = await Test2Facet.deploy()
      await test2Facet.deployed()
      addresses.push(test2Facet.address)
      const selectors = getSelectors(test2Facet)
      tx = await diamondCutFacet.diamondCut(
        [{
          facetAddress: test2Facet.address,
          action: FacetCutAction.Add,
          functionSelectors: selectors
        }],
        ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
      receipt = await tx.wait()
      if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`)
      }
      result = await diamondLoupeFacet.facetFunctionSelectors(test2Facet.address)
      assert.sameMembers(result, selectors)
    })
  
    it('should remove some test2 functions', async () => {
      const test2Facet = await ethers.getContractAt('Test2Facet', diamondAddress)
      const functionsToKeep = ['test2Func1()', 'test2Func5()', 'test2Func6()', 'test2Func19()', 'test2Func20()']
      const selectors = getSelectors(test2Facet).remove(functionsToKeep)
      tx = await diamondCutFacet.diamondCut(
        [{
          facetAddress: ethers.constants.AddressZero,
          action: FacetCutAction.Remove,
          functionSelectors: selectors
        }],
        ethers.constants.AddressZero, '0x', { gasLimit: 800000 })
      receipt = await tx.wait()
      if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`)
      }
      result = await diamondLoupeFacet.facetFunctionSelectors(addresses[4])
      assert.sameMembers(result, getSelectors(test2Facet).get(functionsToKeep))
    })
  
  
});