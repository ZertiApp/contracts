//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Vote.sol";

contract VoteFactory {
  address public owner;
  address public impl;

  constructor (address _impl) {
    owner = msg.sender;
    impl = _impl;
  }

  /*
  function cloneVote() public {
    deployMinimal(impl, "");
  }
  */

}