const hre = require("hardhat");
const { getSelectors, FacetCutAction } = require("./libraries/diamond.js");

const ownerAddress = "0x8FB40436758Ea9e1a8317f54293Af74be02faFf0";
const DiamondInitAddress = "0x543ef797ecDa9E39AB2a4B95640e3eb46f1c27F4";
const FacetNames = {
  DiamondCutFacet: "0xc406a4F055B3273c1338eb8dcf74E5995572919D",
  DiamondLoupeFacet: "0xA18B294b7d1abB86F4D5bc1884591cc31392FFE7",
  OwnershipFacet: "0x4115f8ceC88aC6231C3d947CD7D56246647d531e",
};

const diamondArgs = async () => {
  const diamondInit = await ethers.getContractAt(
    "DiamondInit",
    DiamondInitAddress
  );
  const functionCall = diamondInit.interface.encodeFunctionData("init");
  return {
    owner: ownerAddress,
    init: DiamondInitAddress,
    initCalldata: functionCall,
  };
};

const facetCuts = async () => {
  const facetCuts = [];
  for (const [FacetName, FacetAddress] of Object.entries(FacetNames)) {
    const facet = await ethers.getContractAt(FacetName, FacetAddress);
    facetCuts.push({
      facetAddress: facet.address,
      action: FacetCutAction.Add,
      functionSelectors: getSelectors(facet),
    });
  }
  return facetCuts;
};

/* async function ret() {
  console.log(JSON.stringify([await facetCuts(), await diamondArgs()]));
}

ret(); */

module.exports = [
  [
    {
      facetAddress: "0xc406a4F055B3273c1338eb8dcf74E5995572919D",
      action: 0,
      functionSelectors: ["0x1f931c1c"],
    },
    {
      facetAddress: "0xA18B294b7d1abB86F4D5bc1884591cc31392FFE7",
      action: 0,
      functionSelectors: [
        "0xcdffacc6",
        "0x52ef6b2c",
        "0xadfca15e",
        "0x7a0ed627",
        "0x01ffc9a7",
      ],
    },
    {
      facetAddress: "0x4115f8ceC88aC6231C3d947CD7D56246647d531e",
      action: 0,
      functionSelectors: ["0x8da5cb5b", "0xf2fde38b"],
    },
  ],
  {
    owner: "0x8FB40436758Ea9e1a8317f54293Af74be02faFf0",
    init: "0x543ef797ecDa9E39AB2a4B95640e3eb46f1c27F4",
    initCalldata: "0xe1c7392a",
  },
];
