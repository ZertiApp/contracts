//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EIP1167.sol";
import "./Vote.sol";

interface VoteInit {
    function initialize(address _sender) external;
}

contract VoteFactory is MinimalProxy {

  address public owner;
  address public impl;

  constructor (address _impl) {
    owner = msg.sender;
    impl = _impl;
  }

  modifier onlyOwner() {
    require(msg.sender == owner,"Access denied");
    _;
  }

  /**
   * @dev change implementation adress
   *
   * @param _newImpl adress of the new implemention/contract to be cloned
   */
  function changeImpl(address _newImpl) public onlyOwner {
    impl = _newImpl;
    return;
  }

  /**
   * @dev clone and init Vote function
   */
  function createVote() public payable {
    address voteproxy = this.deployMinimal(impl);
    VoteInit(voteproxy).initialize(msg.sender);
    return;
  }
  
}