//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EIP1167.sol";
import "./Vote.sol";

contract VoteFactory is MinimalProxy {

  address public adm;
  address public impl;

  constructor (address _impl) {
    adm = msg.sender;
    impl = _impl;
  }

  modifier onlyOwner(){
    require(msg.sender == adm,"Access denied");
    _;
  }

  function changeImpl(address _newImpl) public onlyOwner{
    impl = _newImpl;
  }

  function createVote() public {
    this.deployMinimal(impl);
  }
  
}