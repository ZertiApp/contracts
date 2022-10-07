//SPDX-License-Identifier: MIT

/**
 * @notice Library for Subcription Structs
 * @author Lucas Martín Grasso Ramos <lucasgrassoramos@gmail.com>
 *
 */

pragma solidity >=0.8.9;

library LibSubscriptionStructs { 

    /**
     * @notice Plan struct
     * @param name The name of the plan
     * @param cost The cost of the plan
     * @param duration The duration of the plan
     */
    struct Plan {
        uint256 id;
        string name;
        uint256 cost;
        uint256 duration;
    }

    /**
     * @notice Subscription struct
     * @param planId The id of the plan of the subscription
     * @param startTime Start time of the subscription(Unix)
     * @param endTime End time of the subscription(Unix)
     */
    struct Subscription {
        uint256 planId;
        uint256 startTime;
        uint256 endTime;
    }
}
