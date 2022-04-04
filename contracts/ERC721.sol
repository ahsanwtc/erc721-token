// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

library AddressUtils {

  /**
   * @dev Returns whether the target address is a contract.
   * @param _addr Address to check.
   */
  function isContract(address _addr) internal view returns (bool) {
    uint256 size;

    /**
     * XXX Currently there is no better way to check if there is a contract in an address than to
     * check the size of the code at that address.
     * See https://ethereum.stackexchange.com/a/14016/36603 for more details about how this works.
     * TODO: Check this again before the Serenity release, because all addresses will be
     * contracts then.
     */
    assembly { size := extcodesize(_addr) } // solium-disable-line security/no-inline-assembly
    return size > 0;
  }

}

interface IERC721 /* is ERC165 */ {
  /// @dev This emits when ownership of any NFT changes by any mechanism.
  ///  This event emits when NFTs are created (`from` == 0) and destroyed
  ///  (`to` == 0). Exception: during contract creation, any number of NFTs
  ///  may be created and assigned without emitting Transfer. At the time of
  ///  any transfer, the approved address for that NFT (if any) is reset to none.
  event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

  /// @dev This emits when the approved address for an NFT is changed or
  ///  reaffirmed. The zero address indicates there is no approved address.
  ///  When a Transfer event emits, this also indicates that the approved
  ///  address for that NFT (if any) is reset to none.
  event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

  /// @dev This emits when an operator is enabled or disabled for an owner.
  ///  The operator can manage all NFTs of the owner.
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  /// @notice Count all NFTs assigned to an owner
  /// @dev NFTs assigned to the zero address are considered invalid, and this
  ///  function throws for queries about the zero address.
  /// @param _owner An address for whom to query the balance
  /// @return The number of NFTs owned by `_owner`, possibly zero
  function balanceOf(address _owner) external view returns (uint256);

  /// @notice Find the owner of an NFT
  /// @dev NFTs assigned to zero address are considered invalid, and queries
  ///  about them do throw.
  /// @param _tokenId The identifier for an NFT
  /// @return The address of the owner of the NFT
  function ownerOf(uint256 _tokenId) external view returns (address);

  /// @notice Transfers the ownership of an NFT from one address to another address
  /// @dev Throws unless `msg.sender` is the current owner, an authorized
  ///  operator, or the approved address for this NFT. Throws if `_from` is
  ///  not the current owner. Throws if `_to` is the zero address. Throws if
  ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
  ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
  ///  `onERC721Received` on `_to` and throws if the return value is not
  ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
  /// @param _from The current owner of the NFT
  /// @param _to The new owner
  /// @param _tokenId The NFT to transfer
  /// @param data Additional data with no specified format, sent in call to `_to`
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;

  /// @notice Transfers the ownership of an NFT from one address to another address
  /// @dev This works identically to the other function with an extra data parameter,
  ///  except this function just sets data to "".
  /// @param _from The current owner of the NFT
  /// @param _to The new owner
  /// @param _tokenId The NFT to transfer
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

  /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
  ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
  ///  THEY MAY BE PERMANENTLY LOST
  /// @dev Throws unless `msg.sender` is the current owner, an authorized
  ///  operator, or the approved address for this NFT. Throws if `_from` is
  ///  not the current owner. Throws if `_to` is the zero address. Throws if
  ///  `_tokenId` is not a valid NFT.
  /// @param _from The current owner of the NFT
  /// @param _to The new owner
  /// @param _tokenId The NFT to transfer
  function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

  /// @notice Change or reaffirm the approved address for an NFT
  /// @dev The zero address indicates there is no approved address.
  ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
  ///  operator of the current owner.
  /// @param _approved The new approved NFT controller
  /// @param _tokenId The NFT to approve
  function approve(address _approved, uint256 _tokenId) external payable;

  /// @notice Enable or disable approval for a third party ("operator") to manage
  ///  all of `msg.sender`'s assets
  /// @dev Emits the ApprovalForAll event. The contract MUST allow
  ///  multiple operators per owner.
  /// @param _operator Address to add to the set of authorized operators
  /// @param _approved True if the operator is approved, false to revoke approval
  function setApprovalForAll(address _operator, bool _approved) external;

  /// @notice Get the approved address for a single NFT
  /// @dev Throws if `_tokenId` is not a valid NFT.
  /// @param _tokenId The NFT to find the approved address for
  /// @return The approved address for this NFT, or the zero address if there is none
  function getApproved(uint256 _tokenId) external view returns (address);

  /// @notice Query if an address is an authorized operator for another address
  /// @param _owner The address that owns the NFTs
  /// @param _operator The address that acts on behalf of the owner
  /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
  function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

/// @dev Note: the ERC-165 identifier for this interface is 0x150b7a02.
interface IERC721TokenReceiver {
  /// @notice Handle the receipt of an NFT
  /// @dev The ERC721 smart contract calls this function on the recipient
  ///  after a `transfer`. This function MAY throw to revert and reject the
  ///  transfer. Return of other than the magic value MUST result in the
  ///  transaction being reverted.
  ///  Note: the contract address is always the message sender.
  /// @param _operator The address which called `safeTransferFrom` function
  /// @param _from The address which previously owned the token
  /// @param _tokenId The NFT identifier which is being transferred
  /// @param _data Additional data with no specified format
  /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
  ///  unless throwing
  function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);
}

contract ERC721 is IERC721 {
  using AddressUtils for address;
  mapping(address => uint) private ownerToTokenCount;
  mapping(uint => address) private tokenToOwner;
  mapping(uint => address) private tokenToApproved;
  mapping(address => mapping(address => bool)) private ownerToOperator;
  bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
  address public admin;
  uint nextTokenId;

  constructor() {
    admin = msg.sender;
  }

  function mint() external onlyAdmin {
    ownerToTokenCount[msg.sender]++;
    tokenToOwner[nextTokenId] = msg.sender;
    emit Transfer(address(0), msg.sender, nextTokenId);
    nextTokenId++;
  }

  function balanceOf(address _owner) external view override returns (uint) {
    return ownerToTokenCount[_owner];
  }

  function ownerOf(uint _tokenId) external view override returns (address) {
    return tokenToOwner[_tokenId];
  }

  function safeTransferFrom(address _from, address _to, uint _tokenId, bytes calldata data) external override payable {
    _safeTransfer(_from, _to, _tokenId, data);
  }

  function safeTransferFrom(address _from, address _to, uint _tokenId) external override payable {
    _safeTransfer(_from, _to, _tokenId, "");
  }

  function transferFrom(address _from, address _to, uint _tokenId) external override payable {
    _transfer(_from, _to, _tokenId);
  }

  function approve(address _approved, uint _tokenId) external override payable {
    address _owner = tokenToOwner[_tokenId];
    require(msg.sender == _owner, "not authorized");
    tokenToApproved[_tokenId] = _approved;
    emit Approval(_owner, _approved, _tokenId);
  }

  function setApprovalForAll(address _operator, bool _approved) external override {
    ownerToOperator[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  function getApproved(uint _tokenId) external view override returns (address) {
    return tokenToApproved[_tokenId];
  }

  function isApprovedForAll(address _owner, address _operator) external view override returns (bool) {
    return ownerToOperator[_owner][_operator];
  }

  function _safeTransfer(address _from, address _to, uint _tokenId, bytes memory data) internal {
    if (_to.isContract()) {
      bytes4 code = IERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data);
      require(code == MAGIC_ON_ERC721_RECEIVED, "recepient can't ERC721 tokens");
    }

    _transfer(_from, _to, _tokenId);
  }

  function _transfer(address _from, address _to, uint _tokenId) internal canTransfer(_tokenId) {
    ownerToTokenCount[_from]--;
    ownerToTokenCount[_to]++;
    tokenToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }

  function getMagicNumber() public pure returns(bytes4) {
    return MAGIC_ON_ERC721_RECEIVED;
  }

  modifier canTransfer(uint _tokenId) {
    /* owner can transfer token */
    /* approved address by owner can transfer token */
    /* operator can transfer token */
    address _owner = tokenToOwner[_tokenId];
    address _approved = tokenToApproved[_tokenId];
    bool isOperatorApproved = ownerToOperator[_owner][msg.sender]; 
    require(_owner == msg.sender || _approved == msg.sender || isOperatorApproved == true, "not authorized to transfer");
    _;
  }

  modifier onlyAdmin() {
    require(admin == msg.sender, "only admin");
    _;
  }
}