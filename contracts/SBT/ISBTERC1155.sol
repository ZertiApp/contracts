// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @dev Interface of the MSSBT
 */
interface ISBTERC1155 {

    /**
     * @dev Emitted when `newOwner` claims or rejects pending `id`.
     */
    event TokenClaimed(address indexed newOwner, uint256 id);

    /**
     * @dev Emitted when `from` transfers token under `id` to every address at `to[]`.
     */
    event TransferMulti(address indexed from, address[] indexed to, uint256 indexed id);

    /**
     * @dev Get tokens owned by a given address
     */
    function tokensFrom(address from) external view returns (uint256[] memory);

    /**
     * @dev Get tokens marked as pending of a given address
     */
    function pendingFrom(address from) external view returns (uint256[] memory);
    
    /**
     * @dev Claims or Reject pending `_id` from address `_account`.
     *
     * Requirements:
     * - `account` cannot be the zero address.
     * - `account` must have a pending token under `id` at the moment of call.
     * - `account` mUST not own a token under `id` at the moment of call.
     *
     * Emits a {TokenClaimed} event.
     *
     */
    function claimOrReject(uint256 _id,bool _action) external;

    /**
     * @dev Transfers `_id` token from `_from` to every address at `_to[]`.
     *
     * Requirements:
     *
     * - `_from` must be the creator(minter) of `id`.
     * - All addresses in `to[]` must be non-zero.
     * - All addresses in `to[]` must have the token `id` marked as pending.
     * - All addresses in `to[]` must must not own a token type under `id`.
     *
     * Emits a {TransfersMulti} event.
     *
     */
    function safeMultiTransfer (address from, address[] memory to, uint256 id) external;

}