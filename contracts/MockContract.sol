// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract MockContract { }

contract MockGoodContract {
  function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) pure external returns(bytes4) {
      return bytes4(0x150b7a02);
    }
}

contract MockBadContract {
  function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) pure external returns(bytes4) {
      return bytes4(0x150b7a01);
    }
}
