const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const ERC721 = artifacts.require("ERC721");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract('ERC721', accounts => {
  let nft = null;
  const [admin, user, operatorForUser, approvedByAdmin] = accounts;
  const tokenOne = 0, tokenTwo = 1, tokenThree = 2;
  
  before(async () => {
    nft = await ERC721.deployed();
  });

  it('should deploy correctly', async () => {
    assert((await nft.admin()) == admin);
  });

  it('should mint a new token', async () => {
    const transaction = await nft.mint({ from: admin });
    assert((await nft.balanceOf(admin)).toNumber() == 1);
    assert((await nft.ownerOf(tokenOne)) == admin);
    await expectEvent(transaction, 'Transfer', {
      _from: '0x0000000000000000000000000000000000000000',
      _to: admin,
      _tokenId: web3.utils.toBN(tokenOne)
    });
  });

  it('should NOT mint token if caller is not admin', async () => {
    await expectRevert(
      nft.mint({ from: user }),
      'only admin'
    );
  });

  it('should transfer token', async () => {
    const transaction = await nft.transferFrom(admin, user, tokenOne, { from: admin });
    await expectEvent(transaction, 'Transfer', {
      _from: admin,
      _to: user,
      _tokenId: web3.utils.toBN(tokenOne)
    });
    assert((await nft.balanceOf(admin)).toNumber() == 0);
    assert((await nft.balanceOf(user)).toNumber() == 1);
    assert((await nft.ownerOf(tokenOne)) == user);
  });

  it('should NOT transfer token if balance is 0', async () => {
    /* admin has no more tokens */
    await expectRevert(
      nft.transferFrom(admin, user, tokenOne, { from: admin }),
      'not authorized to transfer'
    );

    /* admin is not  has no more tokens */
    await expectRevert(
      nft.safeTransferFrom(admin, user, tokenOne, { from: admin }),
      'not authorized to transfer'
    );
  });

});
