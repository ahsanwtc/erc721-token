const { expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const ERC721 = artifacts.require("ERC721");
const MockContract = artifacts.require('MockContract');
const MockGoodContract = artifacts.require("MockGoodContract");
const MockBadContract = artifacts.require("MockBadContract");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract('ERC721', accounts => {
  let nft = null;
  const [admin, user, operatorForUser, otherUser] = accounts;
  const tokenOne = 0, tokenTwo = 1, tokenThree = 2;
  
  beforeEach(async () => {
    nft = await ERC721.new();
    for (let i = 0; i < 3; i++) {
      await nft.mint({ from: admin });
    }
  });

  it('should deploy correctly', async () => {
    assert((await nft.admin()) === admin);
  });

  it('should mint a new token', async () => {
    const transaction = await nft.mint({ from: admin });
    assert((await nft.balanceOf(admin)).toNumber() == 4);
    assert((await nft.ownerOf(3)) == admin);
    await expectEvent(transaction, 'Transfer', {
      _from: '0x0000000000000000000000000000000000000000',
      _to: admin,
      _tokenId: web3.utils.toBN(3)
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
    assert((await nft.balanceOf(admin)).toNumber() === 2);
    assert((await nft.balanceOf(user)).toNumber() === 1);
    assert((await nft.ownerOf(tokenOne)) === user);
  });

  it('should NOT transfer token if balance is 0', async () => {
    await nft.transferFrom(admin, user, tokenOne, { from: admin });
    await nft.transferFrom(admin, user, tokenTwo, { from: admin });
    await nft.transferFrom(admin, user, tokenThree, { from: admin });

    /* admin has no more tokens */
    await expectRevert(
      nft.transferFrom(admin, user, 3, { from: admin }),
      'not authorized to transfer'
    );

    /* admin is not  has no more tokens */
    await expectRevert(
      nft.safeTransferFrom(admin, user, 3, { from: admin }),
      'not authorized to transfer'
    );
  });

  it('should approve', async () => {
    await nft.transferFrom(admin, user, tokenOne, { from: admin });
    const transaction = await nft.approve(operatorForUser, tokenOne, { from: user });
    const approved = await nft.getApproved(tokenOne);
    assert(approved === operatorForUser);
    await expectEvent(transaction, 'Approval', {
      _owner: user,
      _approved: operatorForUser,
      _tokenId: web3.utils.toBN(tokenOne)
    });
  });

  it('should NOT approve if caller is not owner', async () => {
    await expectRevert(
      nft.approve(operatorForUser, tokenOne, { from: user }),
      'not authorized'
    );
  });

  it('should approve for all', async () => {
    const transaction = await nft.setApprovalForAll(operatorForUser, true, { from: user });
    const isApprovedForAll = await nft.isApprovedForAll(user, operatorForUser);
    assert(isApprovedForAll === true);
    await expectEvent(transaction, 'ApprovalForAll', {
      _owner: user,
      _operator: operatorForUser,
      _approved: true
    });
  });

  it('should disapprove for all', async () => {
    const transaction = await nft.setApprovalForAll(operatorForUser, false, { from: user });
    const isApprovedForAll = await nft.isApprovedForAll(user, operatorForUser);
    assert(isApprovedForAll === false);
    await expectEvent(transaction, 'ApprovalForAll', {
      _owner: user,
      _operator: operatorForUser,
      _approved: false
    });
  });

  it('should NOT transfer if receiver does not implement IERC721TokenReceiver', async () => {
    const recepient = await MockContract.new();
    try {
      await nft.safeTransferFrom(admin, recepient.address, tokenTwo, { from: admin });
    } catch (error) {
      assert(true);
    }

    const mockBadContract = await MockBadContract.new();
    await expectRevert(
      nft.safeTransferFrom(admin, mockBadContract.address, tokenTwo, { from: admin }),
      'recepient can\'t ERC721 tokens'
    );
    assert((await nft.ownerOf(tokenTwo)) === admin);
  });

  it('should transfer from an approved address', async () => {
    await nft.transferFrom(admin, user, tokenOne, { from: admin });
    await nft.transferFrom(admin, user, tokenThree, { from: admin });

    await nft.approve(operatorForUser, tokenOne, { from: user });
    await nft.approve(operatorForUser, tokenThree, { from: user });

    const balanceOfUserBefore = await nft.balanceOf(user);
    const balanceOfOtherUserBefore = await nft.balanceOf(otherUser);

    await nft.transferFrom(user, otherUser, tokenOne, { from: operatorForUser });
    await nft.transferFrom(user, otherUser, tokenOne, { from: operatorForUser });

    const balanceOfUserAfter = await nft.balanceOf(user);
    const balanceOfOtherUserAfter = await nft.balanceOf(otherUser);

    assert(balanceOfUserBefore.toNumber() === 2, 'user balance is not 2');
    assert(balanceOfUserAfter.isZero(), 'user balance is not 0');
    assert(balanceOfOtherUserAfter.sub(balanceOfOtherUserBefore).toNumber() === 2, 'other user balance is not 2');
  });

});
