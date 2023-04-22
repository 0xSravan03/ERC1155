const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deployer } = await getNamedAccounts();
  const { deploy, log } = deployments;

  const ARGS = ["ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/"];

  log("Deploying MyToken Contract");
  const MyToken = await deploy("MyToken", {
    from: deployer,
    args: ARGS,
    log: true,
  });
  log(`Contract deployed successfully at ${MyToken.address}`);
};

module.exports.tags = ["all", "mytoken"];
