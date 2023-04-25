const { ethers, getNamedAccounts, deployments } = require("hardhat");
const { assert, expect } = require("chai");

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

  it("shouldn't able to mint more than maxsupply", async function () {
    await expect(
      Token.mint(1, 99, {
        value: ethers.utils.parseEther(`${0.01 * 99}`),
      })
    ).to.be.revertedWithCustomError(Token, "SupplyLimitExceeded"); // reverting with custom error
  });

  it("should return the right uri", async function () {
    const expectedURI =
      "ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/1.json";
    const result = await Token.uri(1);
    assert.equal(expectedURI, result);
  });
});
