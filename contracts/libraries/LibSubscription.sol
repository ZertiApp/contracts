//SPDX-License-Identifier: MIT

/**
 * @notice Library for Subcription facets
 * @author Lucas Martín Grasso Ramos <lucasgrassoramos@gmail.com>
 *
 */

pragma solidity >=0.8.9;

import { LibSubscriptionStructs } from "./LibSubscriptionStructs.sol";

library LibSubscription {
    bytes32 internal constant SUBSCRIPTION_STORAGE_POSITION =
        keccak256("subscription.facet.storage");

    event PlanUpdated(LibSubscriptionStructs.Plan, uint256 indexed id, bool action);
    event UserSubscription(address indexed account, LibSubscriptionStructs.Subscription);

    struct SubscriptionStorage {
        uint256 nonce;
        mapping(uint256 => LibSubscriptionStructs.Plan) plans;
        mapping(address => LibSubscriptionStructs.Subscription) subscriptions;
    }

    /**
     * @dev Returns the SubscriptionStorage struct.
     */
    function diamondStorage()
        internal
        pure
        returns (SubscriptionStorage storage ds)
    {
        bytes32 position = SUBSCRIPTION_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    /**
     * @dev see {ISubscription-getPlan}
     */
    function getPlan(uint256 id) internal view returns (LibSubscriptionStructs.Plan memory) {
        SubscriptionStorage storage ds = diamondStorage();
        return ds.plans[id];
    }

    /**
     * @dev see {ISubscription-getSubscription}
     */
    function getSubcription(address account)
        internal
        view
        returns (LibSubscriptionStructs.Subscription memory)
    {
        SubscriptionStorage storage ds = diamondStorage();
        return ds.subscriptions[account];
    }

    /**
     * @dev see {ISubscription-createPlan}
     */
    function createPlan(
        string memory name,
        uint256 cost,
        uint256 duration
    ) internal {
        SubscriptionStorage storage ds = diamondStorage();
        LibSubscriptionStructs.Plan memory newPlan = LibSubscriptionStructs.Plan(ds.nonce, name, cost, duration * 1 days);
        ds.plans[ds.nonce] = newPlan;
        emit PlanUpdated(newPlan, ds.nonce, true);
        ds.nonce++;
    }

    /**
     * @dev see {ISubscription-deletePlan}
     */
    function deletePlan(uint256 id) internal {
        SubscriptionStorage storage ds = diamondStorage();
        emit PlanUpdated(ds.plans[id], id, false);
        delete ds.plans[id];
    }

    /**
     * @dev see {ISubscription-subscribe}
     */
    function subscribe (uint256 id) internal {
        SubscriptionStorage storage ds = diamondStorage();
        LibSubscriptionStructs.Plan memory plan = ds.plans[id];
        LibSubscriptionStructs.Subscription memory userSubscription = LibSubscriptionStructs.Subscription(
            plan.id,
            block.timestamp,
            block.timestamp + plan.duration
        );

        ds.subscriptions[msg.sender] = userSubscription;

        emit UserSubscription(msg.sender, userSubscription);
    }

}
