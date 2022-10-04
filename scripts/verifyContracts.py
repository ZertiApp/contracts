import subprocess

deployedContracts = [
    "0x418b9ea7ce06a68b28af897b292fb67a0404dec1", #AddSuportedInterfacesFacet
    "0x543ef797ecDa9E39AB2a4B95640e3eb46f1c27F4", #DiamondInit
    "0x55cdcadc6e819b4907a50a59dcc706b88ce31e49", #ERC5516Facet
    "0xb0c0d4893edcd40705f8db0b4ae120847646d48a", #DiamondCutFacet
    "0x09bf1a98499baa435802784542efdc21423db774", #DiamondLoupeFacet
    "0x4d92e367e72ba9eD2a5201E15bcf8BF505dD4348", #OwnershipFacet
    "0x667855326c5cb7C9Edaf897bC3f14E552fD84955", #ZertiDiamond
]

AddressesToValidate = [
    "0x418b9ea7ce06a68b28af897b292fb67a0404dec1"
]

for address in AddressesToValidate:
    command = f'npx hardhat verify --network goerli "{address}"'
    if address == "0x667855326c5cb7C9Edaf897bC3f14E552fD84955":
        command += " --constructor-args scripts/arguments.js"
    print("Running command: " + command)
    process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
    output, error = process.communicate()

    print(output.decode("utf-8"))
    if error != None:
        print("Error: " + error.decode("utf-8"))
