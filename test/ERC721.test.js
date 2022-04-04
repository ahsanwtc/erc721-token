const ERC721 = artifacts.require("ERC721");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract('ERC721', accounts => {
  let nft = null;
  const [admin] = accounts;
  
  before(async () => {
    nft = await ERC721.deployed();
  });

  it('should deploy correctly', async () => {
    assert((await nft.admin()) == admin);
  });

});
