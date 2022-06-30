//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @dev Interface of the VoteFactory Conta
 */
interface IVF {
    function isEntity(address _addr) external view returns (bool);
}