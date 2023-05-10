//SPDX-License-Identifier: MIT

/**
 * @notice Implementation of the eip-5516 interface.
 * Note: this implementation only allows for each user to own only 1 token type for each `id`.
 * @author Lucas Martín Grasso Ramos <lucasgrassoramos@gmail.com>
 * See https://eips.ethereum.org/EIPS/eip-5516
 *
 */

pragma solidity >=0.8.9;

library LibERC5516 {
	uint256 nonce;
	// Mapping from token ID to account balances
	mapping(address => mapping(uint256 => bool)) balances;
	// Mapping from address to mapping id bool that states if address has tokens(under id) awaiting to be claimed
	mapping(address => mapping(uint256 => bool)) pendings;
	// Mapping from account to operator approvals
	mapping(address => mapping(address => bool)) operatorApprovals;
	// Mapping from ID to minter address.
	mapping(uint256 => address) tokenMinters;
	// Mapping from ID to URI.
	mapping(uint256 => string) tokenUris;
	// Used as the URI for all token types by relying on ID substitution, e.g. https://ipfs.io/ipfs/token.data
	string uri;
	string name;
	string symbol;
	string contractUri;

	/**
	 * @dev Retrieves the nonce
	 */
	function getNonce() internal view returns (uint256) {
		return nonce;
	}

	/**
	 * @dev Increments the nonce
	 */
	function addToNonce() internal {
		nonce++;
	}

	/**
	 * @dev Sets the balance state of a token for an account
	 * @param _account The account to set the balance state for
	 * @param _id The id of the token to set the balance state for
	 */
	function setBalance(address _account, uint256 _id, bool balance) internal {
		balances[_account][_id] = balance;
	}

	/**
	 * @dev See {IERC5516-balanceOf}.
	 */
	function getBalance(address _account, uint256 _id) internal view returns (bool) {
		return balances[_account][_id];
	}

	/**
	 * @dev Sets the pending state of a token for an account
	 * @param _account The account to set the pending state for
	 * @param _id The id of the token to set the pending state for
	 */
	function setPending(address _account, uint256 _id, bool pending) internal {
		pendings[_account][_id] = pending;
	}

	/**
	 * @dev Returns true if the given address has tokens of the given ID awaiting to be claimed.
	 * @param _account The address to query the tokens of.
	 * @param _id The ID of the token to be queried.
	 */
	function getPending(address _account, uint256 _id) internal view returns (bool) {
		return pendings[_account][_id];
	}

	/**
	 * @dev See {IERC1155-setApprovalForAll}.
	 */
	function setApproval(address _owner, address _operator, bool _approved) internal {
		operatorApprovals[_owner][_operator] = _approved;
	}

	/**
	 * @dev See {IERC1155-isApprovedForAll}.
	 */
	function getApproved(address _owner, address _operator) internal view returns (bool) {
		return operatorApprovals[_owner][_operator];
	}

	/**
	 * @notice Sets the minter of a token type.
	 * @param _id The ID of the token type.
	 * @param _minter The address of the minter.
	 */
	function setTokenMinter(uint256 _id, address _minter) internal {
		tokenMinters[_id] = _minter;
	}

	/**
	 * @notice Returns the minter of the token with id `_id`.
	 * @param _id The id of the token.
	 * @return The minter of the token.
	 */
	function getTokenMinter(uint256 _id) internal view returns (address) {
		return tokenMinters[_id];
	}

	/**
	 * @dev Sets the URI for a given token ID
	 * @param _id uint256 ID of the token to set its URI
	 * @param _uri string URI to assign
	 */
	function setTokenURI(uint256 _id, string memory _uri) internal {
		tokenUris[_id] = _uri;
	}

	/**
	 * @dev Returns the URI for a given token ID.
	 */
	function getTokenURI(uint256 _id) internal view returns (string memory) {
		return tokenUris[_id];
	}
}
