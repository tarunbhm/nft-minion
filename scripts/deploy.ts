import { ethers } from "@nomiclabs/buidler";

// Kovan minion address
const minionAddress = "0x98B550E95E90ADFA6D9841fAB937D81FcFEab6D2";

async function main() {
  const factory = await ethers.getContractFactory("MinionNFT");

  // If we had constructor arguments, they would be passed into deploy()
  const contract = await factory.deploy("Welcome NFT", "DWT", minionAddress);

  // The address that the Contract WILL have once mined
  console.log("Deployed contract at:", contract.address);

  // The transaction that was sent to the network to deploy the Contract
  console.log("Deployment transaction hash is:", contract.deployTransaction.hash);

  // The contract is NOT deployed yet; we must wait until it is mined
  await contract.deployed();
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

