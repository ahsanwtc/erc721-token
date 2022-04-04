const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const ERC721 = artifacts.require("ERC721");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract('ERC721', accounts => {
  let nft = null;
  const [admin, user] = accounts;
  
  before(async () => {
    nft = await ERC721.deployed();
  });

  it('should deploy correctly', async () => {
    assert((await nft.admin()) == admin);
  });

  it('should mint a new token', async () => {
    const transaction = await nft.mint({ from: admin });
    assert((await nft.balanceOf(admin)).toNumber() == 1);
    assert((await nft.ownerOf(0)) == admin);
    await expectEvent(transaction, 'Transfer', {
      _from: '0x0000000000000000000000000000000000000000',
      _to: admin,
      _tokenId: web3.utils.toBN(0)
    });
  });

  it('should NOT mint token if caller is not admin', async () => {
    await expectRevert(
      nft.mint({ from: user }),
      'only admin'
    );
  });



});
