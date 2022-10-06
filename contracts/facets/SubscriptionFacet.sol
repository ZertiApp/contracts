//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";
import { LibSubscription } from  "../libraries/LibSubscription.sol";

contract Subsciption {
    address internal constant OWNERSHIP_FACET_ADDRESS = address(0xDE5e2FF59753AD0625BBBBAa74964fD831359C67);
    address private constant TOKEN_ADDRESS = address(0xDE5e2FF59753AD0625BBBBAa74964fD831359C67);
    IERC20 public constant  TOKEN = IERC20(TOKEN_ADDRESS);

    function viewPlan(uint256 id) external view returns (Plan memory) {
        return LibSubscription.getPlan(id);
    }

    function isSubscribed(address account) external view returns(bool) {
        return block.timestamp < LibSubscription.getSubcription(account).endTime;
    }

    function tokenBalance(address addr) external view returns(uint) {
        return TOKEN.balanceOf(addr);
    }

    function subscribe (uint256 id) external {
        require(TOKEN.allowance(msg.sender, address(this)) >= LibSubscription.getPlan(id).cost, "Subcription: Insufficient allowance");
        LibSubscription.subscribe(id);

    }

    function createPlan(string memory name, uint256 cost, uint256 time) external {
        LibDiamond.enforceIsContractOwner();
        LibSubscription.createPlan(name, cost, time);
    }

    function deletePlan(uint256 id) external {
        LibDiamond.enforceIsContractOwner();
        LibSubscription.deletePlan(id);
    }

}
