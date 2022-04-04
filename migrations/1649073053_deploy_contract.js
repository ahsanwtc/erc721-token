const ERC721 = artifacts.require("ERC721");
const MockContract = artifacts.require("MockContract");
const MockGoodContract = artifacts.require("MockGoodContract");
const MockBadContract = artifacts.require("MockBadContract");

module.exports = async function(_deployer) {
  await _deployer.deploy(ERC721);
  await _deployer.deploy(MockContract);
  await _deployer.deploy(MockGoodContract);
  await _deployer.deploy(MockBadContract);
};
