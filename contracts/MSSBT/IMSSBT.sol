// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @dev Interface of the MSSBT
 */
interface IMSSBT {

    event Transfer(
        address _from,
        address _to,
        uint256 _id
    );

    event Claimed(
        address _newOwner,
        uint256 _id
    );

    function transfer(uint256 id , address to) external returns (bool);

    function multiTransfer(
        uint256 id,
        address[] memory to
    ) external returns (bool);

}