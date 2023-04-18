//SPDX-License-Identifier: CC0-1.0

/**
 * @notice Implementation of the eip-5516 interface.
 * Note: this implementation only allows for each user to own only 1 token type for each `id`.
 * @author Matias Arazi <matiasarazi@gmail.com> , Lucas Martín Grasso Ramos <lucasgrassoramos@gmail.com>
 * See https://eips.ethereum.org/EIPS/eip-5516
 *
 */

pragma solidity >=0.8.9;

library LibERC5516 {
	bytes32 internal constant ERC5516_STORAGE_POSITION = keccak256("ERC5516.facet.storage");

	struct ERC5516Storage {
		// Used for making each token unique, Maintains ID registry and quantity of tokens minted.
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
	}

	/**
	 * @dev Returns the ERC5516Storage struct.
	 */
	function diamondStorage() internal pure returns (ERC5516Storage storage ds) {
		bytes32 position = ERC5516_STORAGE_POSITION;
		assembly {
			ds.slot := position
		}
	}

	/**
	 * @dev Retrieves the nonce
	 */
	function getNonce() internal view returns (uint256) {
		ERC5516Storage storage ds = diamondStorage();
		return ds.nonce;
	}

	/**
	 * @dev Increments the nonce
	 */
	function addToNonce() internal {
		ERC5516Storage storage ds = diamondStorage();
		ds.nonce++;
	}

	/**
	 * @dev Sets the balance state of a token for an account
	 * @param _account The account to set the balance state for
	 * @param _id The id of the token to set the balance state for
	 */
	function setBalance(address _account, uint256 _id, bool balance) internal {
		ERC5516Storage storage ds = diamondStorage();
		ds.balances[_account][_id] = balance;
	}

	/**
	 * @dev See {IERC5516-balanceOf}.
	 */
	function getBalance(address _account, uint256 _id) internal view returns (bool) {
		ERC5516Storage storage ds = diamondStorage();
		return ds.balances[_account][_id];
	}

	/**
	 * @dev Sets the pending state of a token for an account
	 * @param _account The account to set the pending state for
	 * @param _id The id of the token to set the pending state for
	 */
	function setPending(address _account, uint256 _id, bool pending) internal {
		ERC5516Storage storage ds = diamondStorage();
		ds.pendings[_account][_id] = pending;
	}

	/**
	 * @dev Returns true if the given address has tokens of the given ID awaiting to be claimed.
	 * @param _account The address to query the tokens of.
	 * @param _id The ID of the token to be queried.
	 */
	function getPending(address _account, uint256 _id) internal view returns (bool) {
		ERC5516Storage storage ds = diamondStorage();
		return ds.pendings[_account][_id];
	}

	/**
	 * @dev See {IERC1155-setApprovalForAll}.
	 */
	function setApproval(address _owner, address _operator, bool _approved) internal {
		ERC5516Storage storage ds = diamondStorage();
		ds.operatorApprovals[_owner][_operator] = _approved;
	}

	/**
	 * @dev See {IERC1155-isApprovedForAll}.
	 */
	function getApproved(address _owner, address _operator) internal view returns (bool) {
		ERC5516Storage storage ds = diamondStorage();
		return ds.operatorApprovals[_owner][_operator];
	}

	/**
	 * @notice Sets the minter of a token type.
	 * @param _id The ID of the token type.
	 * @param _minter The address of the minter.
	 */
	function setTokenMinter(uint256 _id, address _minter) internal {
		ERC5516Storage storage ds = diamondStorage();
		ds.tokenMinters[_id] = _minter;
	}

	/**
	 * @notice Returns the minter of the token with id `_id`.
	 * @param _id The id of the token.
	 * @return The minter of the token.
	 */
	function getTokenMinter(uint256 _id) internal view returns (address) {
		ERC5516Storage storage ds = diamondStorage();
		return ds.tokenMinters[_id];
	}

	/**
	 * @dev Sets the URI for a given token ID
	 * @param _id uint256 ID of the token to set its URI
	 * @param _uri string URI to assign
	 */
	function setTokenURI(uint256 _id, string memory _uri) internal {
		ERC5516Storage storage ds = diamondStorage();
		ds.tokenUris[_id] = _uri;
	}

	/**
	 * @dev Returns the URI for a given token ID.
	 */
	function getTokenURI(uint256 _id) internal view returns (string memory) {
		ERC5516Storage storage ds = diamondStorage();
		return ds.tokenUris[_id];
	}
}
