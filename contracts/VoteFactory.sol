pragma solidity ^0.5.3;

import "@openzeppelin/upgrades/contracts/upgradeability/ProxyFactory.sol";
import "./Vote.sol";

contract VoteFactory is ProxyFactory {
  address public owner;
  address public impl;

  constructor (address _impl) public {
    owner = msg.sender;
    impl = _impl;
  }

  function cloneVote() public {
    deployMinimal(impl, "");
  }
}