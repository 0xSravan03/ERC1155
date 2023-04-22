const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deployer, tester } = await getNamedAccounts();
  const { deploy, log, get } = deployments;

  const ARGS = ["ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/"];

  log("Deploying MyToken Contract");
  const MyToken = await deploy("MyToken", {
    from: deployer,
    args: ARGS,
    log: true,
  });
  log(`Contract deployed successfully at ${MyToken.address}`);

  const token = await ethers.getContract("MyToken", tester);

  const tokenId = 1;
  const amount = 5;

  const tx = await token.mint(tokenId, amount, {
    value: ethers.utils.parseEther(`${0.01 * amount}`),
  });
  await tx.wait(1);
  console.log(`Minted Token Id ${1}`);
};
