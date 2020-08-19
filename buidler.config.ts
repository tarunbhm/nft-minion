import { BuidlerConfig, usePlugin } from "@nomiclabs/buidler/config";

usePlugin("@nomiclabs/buidler-waffle");
usePlugin("buidler-typechain");

const config: BuidlerConfig = {
  paths: {
    artifacts: "build/contracts",
    tests: "tests"
  },
  solc: {
    version: "0.5.17"
  },
  typechain: {
    outDir: "build/types",
    target: "ethers-v4"
  },
  networks: {
    buidlerevm: {
      gas: 12000000,
      blockGasLimit: 0x1fffffffffffff,
      allowUnlimitedContractSize: true,
      timeout: 1800000
    },
    kovan: {
      url: "https://kovan.infura.io/v3/<api_key>",
      accounts: {
        mnemonic: "<mnemonic>"
      }
    },
    development: {
      url: 'http://localhost:8545'
    }
  },
};

export default config;
