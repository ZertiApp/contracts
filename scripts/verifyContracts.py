import subprocess
import sys

AddressesToValidate = sys.argv[1:]

for address in AddressesToValidate:
    command = f'npx hardhat verify --network polygon "{address}"'

    print("Running: " + command)

    process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
    output, error = process.communicate()

    print(output.decode("utf-8"))
    if error is not None:
        print("Error: " + error.decode("utf-8"))

    sys.stdout.flush()
