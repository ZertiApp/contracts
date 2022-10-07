//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;


/**
 *
 * @author Matias Arazi <matiasarazi@gmail.com> , Lucas Martín Grasso Ramos <lucasgrassoramos@gmail.com>
 *
 */

import { LibSubscriptionStructs } from  "../libraries/LibSubscriptionStructs.sol";

interface ISubscription {

    /**
     * @dev Returns the plan with the given id
     * @param id The id of the plan
     * @return The plan with the given id
     */
    function getPlan(uint256 id) external view returns (LibSubscriptionStructs.Plan memory);

    /**
     * @dev Returns if the given account is subscribed and the plan of the subscription
     * @param account The account to check
     * @return If the given account is subscribed and the plan of the subscription
     */
    function isSubscribed(address account) external view returns(bool, LibSubscriptionStructs.Plan memory);

    /**
     * @dev Returns if the given accounts are subscribed and the plan of the subscription
     * @param accounts The accounts to check
     * @return If the given accounts are subscribed and the plan of the subscription
     */
    function isSubscribedBatch(address[] calldata accounts) external view returns(bool[] memory, LibSubscriptionStructs.Plan[] memory);

    /**
     * @dev Subscribes the sender to the plan with the given id
     * @param id The id of the plan to subscribe to
     */
    function subscribe (uint256 id) external;

    /**
     * @dev Creates a new plan
     * @param name The name of the plan
     * @param cost The cost of the plan
     * @param duration The duration of the plan
     */
    function createPlan(string memory name, uint256 cost, uint256 duration) external;

    /**
     * @dev Deletes the plan with the given id
     * @param id The id of the plan to delete
     */
    function deletePlan(uint256 id) external ;

}
