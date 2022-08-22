// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.4;

/**
    @title Soulbound, Multi-Token, Semi-fungible, Double-Signature Standard.
    @notice Interface of the eip-5516 
    Note: The ERC-165 identifier for this interface is 0xb86868e0.
 */

interface IEIP5516 {

    // Error - `account` is not creator of `id` (any transfer-like function) or does not own `id` (burn)
    error Unauthorized(address account, uint256 id);

    // Error - Address zero is passed as a function parameter
    error AddressZero();

    // Error - `account` already owns `id` or has `id` under pending
    error AlreadyAssignee(address account, uint256 id);

    /**
     * @dev Emitted when `newOwner` claims or rejects pending `id`.
     */
    event TokenClaimed(address indexed operator, address indexed newOwner, uint256 id);

    /**
     * @dev Emitted when `from` transfers token under `id` to every address at `to[]`.
     */
    event TransferMulti(address indexed from, address[] indexed to, uint256 amount, uint256 indexed id);

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
     * - `account` MUST have a pending token under `id` at the moment of call.
     * - `account` MUST not own a token under `id` at the moment of call.
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
     * - `_from` MUST be the creator(minter) of `id`.
     * - All addresses in `to[]` MUST be non-zero.
     * - All addresses in `to[]` MUST have the token `id` under `_pendings`.
     * - All addresses in `to[]` MUST not own a token type under `id`.
     *
     * Emits a {TransfersMulti} event.
     *
     */
    function batchTransfer (address from, address[] memory to, uint256 id, uint256 amount, bytes memory data) external;

}