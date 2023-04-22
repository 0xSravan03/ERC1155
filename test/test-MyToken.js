const { ethers, getNamedAccounts, deployments } = require("hardhat");
const { assert } = require("chai");

describe("MyToken", function () {
  let Token;
  it("should update balance after mint", async function () {
    await deployments.fixture(["mytoken"]);
    const { tester } = await getNamedAccounts();
    Token = await ethers.getContract("MyToken", tester);
    const tx = await Token.mint(1, 5, {
      value: ethers.utils.parseEther(`${0.01 * 5}`),
    });
    await tx.wait(1);
    const balance = await Token.balanceOf(tester, 1);
    assert.equal(balance.toString(), 5);
  });
});
