require("@nomicfoundation/hardhat-toolbox");


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  networks: {
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/rHmGE-_Hs-wE-bklO6h6WKwVzrk5BlQg",
      accounts: ["edd0a374fb70992c742af5ff48618adf91eb6f97656be5ed122a6fc0ff3aed3e"],
    },
  },
  etherscan: {
    apiKey: "788MP8EKS55QBDSMTWAMAAE8QG1E3BBZBG",
  },
};
