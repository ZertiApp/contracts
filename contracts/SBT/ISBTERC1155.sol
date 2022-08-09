// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @dev Interface of the MSSBT
 */
interface ISBTERC1155 {

    /**
     * @dev Emitted when `_newOwner` claims or rejects pending `_tokenId`.
     */
    event TokenClaimed(address indexed _newOwner, uint256 _id);

    function tokensURIFrom(address _from) external view returns (string[] memory);

    function tokensFrom(address _from) external view returns (uint256[] memory);

    function uriOf(uint256 _id) external view returns (string memory);

    function claimOrReject(uint256 _id,bool _action) external;

    function safeMultiTransfer (address from, address[] memory to, uint256 id) external;

}