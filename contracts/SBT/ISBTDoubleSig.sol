// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @dev Interface of the MSSBT
 */
interface ISBTDoubleSig {

    //View
    function uri(uint256) external view  returns (string memory);

    function ownerOf(uint256 _id) external view returns(address);

    function uriOf(uint256 _id) external view  returns(string memory);

    function amountOf(uint256 _id) external view returns(uint256);

    function tokensFrom(address _from) external view returns(uint256[] memory);

    function pendingFrom(address _from) external view returns(uint256[] memory);


    event TokenTransfer(
        address indexed _from,
        address indexed _to,
        uint256 _id
    );

    event TokenClaimed(
        address indexed _newOwner,
        bool claimed,
        uint256 _id
    );

    function transfer(uint256 id , address to) external returns (bool);

    function transferBatch(
        uint256 id,
        address[] memory to
    ) external returns (bool);

    

}