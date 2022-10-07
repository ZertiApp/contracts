//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 *
 * @author Matias Arazi <matiasarazi@gmail.com> , Lucas Martín Grasso Ramos <lucasgrassoramos@gmail.com>
 *
 */

import "../interfaces/ERC20/IERC20.sol";
import "../interfaces/ISubscription.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";
import { LibSubscription } from  "../libraries/LibSubscription.sol";
import { LibSubscriptionStructs } from  "../libraries/LibSubscriptionStructs.sol";

contract SubscriptionFacet is ISubscription{
    address private constant TOKEN_ADDRESS = address(0xFd6CB3CB3cE04c579f35BF5Bd12Ee09141C536EB);
    IERC20 public ZetToken = IERC20(TOKEN_ADDRESS);

    function getPlan(uint256 id) external override view returns (LibSubscriptionStructs.Plan memory) {
        return LibSubscription.getPlan(id);
    }

    function isSubscribed(address account) external override view returns(bool, LibSubscriptionStructs.Plan memory) {
        LibSubscriptionStructs.Subscription memory sub = LibSubscription.getSubcription(account);
        if (sub.endTime > block.timestamp) {
            return (true, LibSubscription.getPlan(sub.planId));
        }
        return (false, LibSubscriptionStructs.Plan(0, "", 0, 0));
    }

    function isSubscribedBatch(address[] calldata accounts) external override view returns(bool[] memory, LibSubscriptionStructs.Plan[] memory) {
        bool[] memory subs = new bool[](accounts.length);
        LibSubscriptionStructs.Plan[] memory plans = new LibSubscriptionStructs.Plan[](accounts.length);
        for (uint256 i = 0; i < accounts.length;){
            LibSubscriptionStructs.Subscription memory sub = LibSubscription.getSubcription(accounts[i]);
            if (sub.endTime > block.timestamp) {
                subs[i] = true;
                plans[i] = LibSubscription.getPlan(sub.planId);
            }
            else {
                subs[i] = false;
                plans[i] = LibSubscriptionStructs.Plan(0, "", 0, 0);
            }
            unchecked {
                ++i;
            }
        }
        return (subs, plans);
    }

    function subscribe (uint256 id) external override {
        require(ZetToken.allowance(msg.sender, address(this)) >= LibSubscription.getPlan(id).cost, "Subscription: Insufficient allowance");
        LibSubscription.subscribe(id);
    }

    function createPlan(string memory name, uint256 cost, uint256 duration) external override {
        LibDiamond.enforceIsContractOwner();
        LibSubscription.createPlan(name, cost, duration);
    }

    function deletePlan(uint256 id) external override {
        LibDiamond.enforceIsContractOwner();
        LibSubscription.deletePlan(id);
    }

}
