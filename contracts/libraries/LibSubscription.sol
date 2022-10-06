//SPDX-License-Identifier: MIT

/**
 * @notice Library for Subcription facets
 * @author Lucas Martín Grasso Ramos <lucasgrassoramos@gmail.com>
 *
 */

pragma solidity >=0.8.9;

library LibSubscription {
    bytes32 internal constant SUBSCRIPTION_STORAGE_POSITION =
        keccak256("subscription.facet.storage");

    struct Plan {
        uint256 id;
        string name;
        uint256 cost;
        uint256 duration;
    }

    struct Subscription {
        uint256 planId;
        uint256 startTime;
        uint256 endTime;
    }

    event PlanUpdated(Plan, uint256 indexed id, bool action);
    event UserSubscription(address indexed account, Subscription);

    struct SubscriptionStorage {
        uint256 nonce;
        mapping(uint256 => Plan) plans;
        mapping(address => Subscription) subscriptions;
    }

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

    function getPlan(uint256 id) external view returns (Plan memory) {
        SubscriptionStorage storage ds = diamondStorage();
        return ds.plans[id];
    }

    function getSubcription(address account)
        external
        view
        returns (Subscription memory)
    {
        SubscriptionStorage storage ds = diamondStorage();
        return ds.subscriptions[account];
    }

    function createPlan(
        string memory name,
        uint256 cost,
        uint256 duration
    ) external {
        SubscriptionStorage storage ds = diamondStorage();
        Plan memory newPlan = Plan(ds.nonce, name, cost, duration);
        ds.plans[ds.nonce] = newPlan;
        emit PlanUpdated(newPlan, ds.nonce, true);
        ds.nonce++;
    }

    function deletePlan(uint256 id) external {
        SubscriptionStorage storage ds = diamondStorage();
        emit PlanUpdated(ds.plans[id], id, false);
        delete ds.plans[id];
    }

    function subscribe (uint256 id) external {
        SubscriptionStorage storage ds = diamondStorage();
        Plan memory plan = ds.plans[id];
        Subscription memory userSubscription = Subscription(
            plan.id,
            block.timestamp,
            block.timestamp + plan.duration
        );

        ds.subscriptions[msg.sender] = userSubscription;

        emit UserSubscription(msg.sender, userSubscription);
    }

}
