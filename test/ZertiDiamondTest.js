
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

    it('should Support ERC1155 interfaces', async () => {
      const ERC5516Facet = await ethers.getContractAt('ERC5516Facet', diamondAddress)
      assert.equal(await ERC5516Facet.supportsInterface("0xd9b67a26"), true); //IERC1155
      assert.equal(await ERC5516Facet.supportsInterface("0x01ffc9a7"), true); //ERC165
      assert.equal(await ERC5516Facet.supportsInterface("0x0e89341c"), true); //IERC1155MetadataURI
    })

    it('should mint, transfer, claim and burn ERC5516 Tokens', async () => {
      const [owner, addr1, addr2] = await ethers.getSigners();
      const ERC5516Facet = await ethers.getContractAt('ERC5516Facet', diamondAddress)

      //Token1
      let tx = await ERC5516Facet.mint("Arbol")
      receipt = await tx.wait()
      if (!receipt.status) {
        throw Error(`tx failed: ${tx.hash}`)
      }
      assert.equal(await ERC5516Facet.uri(1), "https://ipfs.io/ipfs/Arbol");

      tx = await ERC5516Facet.safeTransferFrom(owner.address, addr1.address, 1, 1, "0x")
      receipt = await tx.wait()
      if (!receipt.status) {
        throw Error(`tx failed: ${tx.hash}`)
      }
      await ERC5516Facet.connect(addr1).claimOrReject(addr1.address, 1, true);
      assert.equal(await ERC5516Facet.balanceOf(addr1.address, 1), 1);

      //Token2
      tx = await ERC5516Facet.mint("Araze")
      receipt = await tx.wait()
      if (!receipt.status) {
        throw Error(`tx failed: ${tx.hash}`)
      }
      assert.equal(await ERC5516Facet.uri(2), "https://ipfs.io/ipfs/Araze");
      
      await ERC5516Facet.connect(owner).batchTransfer(owner.address, [addr1.address, addr2.address], 2, 1, "0x")

      let result = await ERC5516Facet.pendingFrom(addr1.address)
      assert.equal(result[0].toNumber(), 2);

      result = await ERC5516Facet.pendingFrom(addr2.address)
      assert.equal(result[0].toNumber(), 2);

      await ERC5516Facet.connect(addr1).claimOrReject(addr1.address, 2, true);
      assert.equal(await ERC5516Facet.balanceOf(addr1.address, 2), 1);
      await ERC5516Facet.connect(addr2).claimOrReject(addr2.address, 2, false);
      assert.equal(await ERC5516Facet.balanceOf(addr2.address, 2), 0);

      await ERC5516Facet.connect(addr1).burn(1)
      receipt = await tx.wait()
      if (!receipt.status) {
        throw Error(`tx failed: ${tx.hash}`)
      }
      assert.equal(await ERC5516Facet.balanceOf(addr1.address, 1), 0);
    })

    it('should mantain storage', async() => {
      const [owner, addr1, addr2] = await ethers.getSigners();
      //remove al ERC5516 functions
      const ERC5516FacetToRemove = await ethers.getContractAt('ERC5516Facet', diamondAddress)
      let selectors = getSelectors(ERC5516FacetToRemove)
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

      const ERC5516FACET = await ethers.getContractFactory('ERC5516Facet')
      const ERC5516Facet = await ERC5516FACET.deploy()
      await ERC5516Facet.deployed()
      selectors = getSelectors(ERC5516Facet).remove(['supportsInterface(bytes4)'])
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

      const ERC5516DiamondFacet = await ethers.getContractAt('ERC5516Facet', diamondAddress)
      assert.equal(await ERC5516DiamondFacet.uri(1), "https://ipfs.io/ipfs/Arbol");
      assert.equal(await ERC5516DiamondFacet.uri(2), "https://ipfs.io/ipfs/Araze");
      
      assert.equal(await ERC5516DiamondFacet.balanceOf(addr1.address, 1), 0);
      assert.equal(await ERC5516DiamondFacet.balanceOf(addr1.address, 2), 1);
      assert.equal(await ERC5516DiamondFacet.balanceOf(addr2.address, 2), 0);

      await ERC5516DiamondFacet.mint("BoquitaPasion")
      assert.equal(await ERC5516DiamondFacet.uri(3), "https://ipfs.io/ipfs/BoquitaPasion");
      
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