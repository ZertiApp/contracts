require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("@primitivefi/hardhat-dodoc");
require("hardhat-gas-reporter");
require("solidity-coverage");

const {
	MAIN_ACCOUNT_PK,
	TEST_ACCOUNT_PK,
	ALCHEMY_API_KEY,
	ALCHEMY_POLYGON_API_KEY,
	POLYGONSCAN_API_KEY,
	COINMARKETCAP_API_KEY,
} = process.env;

task("flat", "Flattens and prints contracts and their dependencies (Resolves licenses)")
	.addOptionalVariadicPositionalParam("files", "The files to flatten", undefined, types.inputFile)
	.setAction(async ({ files }, hre) => {
		let flattened = await hre.run("flatten:get-flattened-sources", { files });

		// Remove every line started with "// SPDX-License-Identifier:"
		flattened = flattened.replace(/SPDX-License-Identifier:/gm, "License-Identifier:");
		flattened = `// SPDX-License-Identifier: MIXED\n\n${flattened}`;

		// Remove every line started with "pragma experimental ABIEncoderV2;" except the first one
		flattened = flattened.replace(/pragma experimental ABIEncoderV2;\n/gm, ((i) => (m) => (!i++ ? m : ""))(0));
		console.log(flattened);
	});

const accountPK = MAIN_ACCOUNT_PK !== "" ? MAIN_ACCOUNT_PK : TEST_ACCOUNT_PK;

module.exports = {
	solidity: {
		compilers: [
			{
				version: "0.8.9",
				settings: {
					optimizer: {
						enabled: true,
						runs: 1000,
					},
				},
			},
		],
	},
	gasReporter: {
		enabled: true,
		currency: "USD",
		token: "MATIC",
		showTimeSpent: true,
		/* outputFile: "docs/this.gasReporter.txt",
		noColors:true, */
		gasPriceApi:
			"https://api.polygonscan.com/api?module=proxy&action=eth_gasPrice",
		coinmarketcap: COINMARKETCAP_API_KEY,
	},
	etherscan: {
		apiKey: POLYGONSCAN_API_KEY,
	},
	networks: {
		goerli: {
			url: `https://eth-goerli.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
		},
		polygon: {
			url: `https://polygon-mainnet.g.alchemy.com/v2/${ALCHEMY_POLYGON_API_KEY}`,
		},
	},
};
