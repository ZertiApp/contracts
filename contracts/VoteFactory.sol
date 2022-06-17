//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EIP1167.sol";
import "./Vote.sol";

/**
 * @dev interface to interact with cloned Vote contracts. Used to call the initialize() function
 *      given that cloned contracts cant have constructors.
 *
 */
interface VoteInit {
    function initialize( 
        uint256 _votingCost,
        uint256 _minVotes,
        uint256 _timeToVote,
        address _sender)  external;
}

contract VoteFactory is MinimalProxy {

  address public owner;
  address public impl; //Adress of the vote contract to be cloned

  constructor (address _impl) {
    owner = msg.sender;
    impl = _impl;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Access denied");
    _;
  }

  /**
   * @dev change implementation adress
   *
   * @param _newImpl adress of the new implemention/contract to be cloned
   */
  function changeImpl(address _newImpl) public onlyOwner {
    impl = _newImpl;
  }

  /**
   * @dev clone and init Vote function
   * 
   */
  function createVote(uint256 _votingCost, uint256 _minVotes, uint256 _timeToVote) public payable {
    require(_votingCost > 0, "Voting cost can't be 0");
    address voteproxy = this.deployMinimal(impl);
    VoteInit(voteproxy).initialize(_votingCost, _minVotes, _timeToVote, msg.sender);
  }
}
