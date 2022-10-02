import subprocess

Addresses = [
    "0x543ef797ecDa9E39AB2a4B95640e3eb46f1c27F4",
    "0xc406a4F055B3273c1338eb8dcf74E5995572919D",
    "0xA18B294b7d1abB86F4D5bc1884591cc31392FFE7",
    "0x4115f8ceC88aC6231C3d947CD7D56246647d531e",
    "0x4d92e367e72ba9eD2a5201E15bcf8BF505dD4348",
    "0x37124e367A4234A6971089e81E488Fc698EcaF8B"
]

for address in Addresses:
    command = f'npx hardhat verify --network goerli "{address}"'
    if address == "0x37124e367A4234A6971089e81E488Fc698EcaF8B":
        command += " --constructor-args scripts/arguments.js"
    print("Running command: " + command)
    process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
    output, error = process.communicate()

    print(output.decode("utf-8"))
    if(error != None):
        print("Error: " + error.decode("utf-8"))
