const { ethers, getNamedAccounts } = require("hardhat");

const tokenId = 1;
const amount = 1;

async function mint(tokenId, amount) {
  const { tester } = await getNamedAccounts();
  const token = await ethers.getContract("MyToken", tester);

  const tx = await token.mint(tokenId, amount, {
    value: ethers.utils.parseEther(`${0.01 * amount}`),
  });
  await tx.wait(1);
  console.log(`Minted Token Id ${1}`);
}

mint(tokenId, amount)
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });

module.exports = {
  mint,
};
