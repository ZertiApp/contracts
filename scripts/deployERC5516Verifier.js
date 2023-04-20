async function main() {
	const verifierContract = "ERC5516Verifier";

	const spongePoseidonLib = "0x12d8C87A61dAa6DD31d8196187cFa37d1C647153";
	const poseidon6Lib = "0xb588b8f07012Dc958aa90EFc7d3CF943057F17d7";


	const ERC5516Verifier_Factory = await ethers.getContractFactory(verifierContract, {
		libraries: {
			SpongePoseidon: spongePoseidonLib,
			PoseidonUnit6L: poseidon6Lib
		},
	});
	const ERC5516Verifier = await ERC5516Verifier_Factory.deploy(
		verifierName,
		verifierSymbol
	);

	await ERC5516Verifier.deployed();
	console.log(verifierName, "deployed at:", ERC5516Verifier.address);
}
main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});