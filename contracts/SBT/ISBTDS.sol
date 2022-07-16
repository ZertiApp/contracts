// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @dev Interface of the MSSBT
 */
interface ISBTDS {

    /**
     * @dev Emitted when `_id` token is transferred from `_from` to `_to`.
     */
    event TokenTransfer(
        address indexed _from,
        address indexed _to,
        uint256 _id
    );

    /**
     * @dev Emitted when `_newOwner` claims or rejects pending `_tokenId`.
     */
    event TokenClaimed(
        address indexed _newOwner,
        uint256 _id
    );

    /**
     * @dev Get URI 
     * @return string of the URI
     */
    function uri() external view returns (string memory);

    /**
     * @dev get ownerOf a tokem, given an ID
     * @param _id uint256 of the ID to be queried
     * @return address address of the owner of the given ID.
     */
    function ownerOf(uint256 _id) external view returns(address);

    /**
     * @dev Get URI of a ID
     * @param _id uint256 of the ID to be queried
     * @return string URI of the ID
     */
    function uriOf(uint256 _id) external view  returns(string memory);

    /**
     * @dev get amount of tokens under ID(Semi-Fungible)
     * @param _id uint256 of the ID to be queried
     * @return uint256 number of tokens under ID
     */
    function amountOf(uint256 _id) external view returns(uint256);

    /**
     * @dev get tokens owned by a given address
     * @param _from addres to get owned tokens from
     * @return uint256[] IDs of all tokens owned by address.
     */
    function tokensFrom(address _from) external view returns(uint256[] memory);

    /**
     * @dev get tokens pending to be claimed by a given address
     * @param _from addres to get pending tokens from
     * @return uint256[] IDs of all tokens pending to be claimed by address.
     */
    function pendingFrom(address _from) external view returns(uint256[] memory);

    /**
     * @dev Transfers `_id` token from `_from` to `_to`.
     *
     * Requirements:
     *
     * - `_from` cannot be the zero address.
     * - `_to` cannot be the zero address.
     * `_to` MUST NOT have a pending token under `_id`.
     * `_from` Must be the minter(owner before assigning `_tokenId` as pending to `_to` ) of `_id`
     * - `_to` cannot own a token under _id at call.
     *
     * Emits a {TokenTransfer} event.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     */
    function transfer(uint256 _id , address _to) external returns (bool);

    /**
     * @dev Transfers `_id` token from `_from` to every address at `_to[]`.
     *
     * Requirements: See {transfer}
     *
     * Calls _transfer len(_to) times
     *
     * Emits a {TokenTransfer} event len(_to) times.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     */
    function transferBatch(uint256 _id, address[] memory _to) external returns (bool);
    
}