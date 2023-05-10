// SPDX-License-Identifier: MIT
/**
 * @title ERC5516Verifier
 * @author Lucas Grasso - Zerti
 * @notice ERC5516Verifier is an ERC5516 token that extends ZKP Polygon ID logic.
 */
pragma solidity ^0.8.0;

import "./ERC5516.sol";
import "./libraries/GenesisUtils.sol";
import "./interfaces/ICircuitValidator.sol";
import "./verifiers/ZKPVerifier.sol";

contract ERC5516Verifier is ERC5516, ZKPVerifier {
	uint256 internal constant TOKEN_AMOUNTS_PER_PROOF_SUBMISSION = 1;

	/**
	 * Event emitted when a token is set for ZKP.
	 * @param requestId id of the ZKP. request
	 * @param tokenId id of the token that was set for ZKP.
	 */
	event ZKPRequestAdded(uint64 indexed requestId, uint256 indexed tokenId);

	/**
	 * @dev Modifier to make a function callable only by the minter of the token under `id`.
	 * @param _id uint256 ID of the token to be minted.
	 */
	modifier onlyMinter(uint256 _id) {
		require(_msgSender() == LibERC5516.getTokenMinter(_id), "Unauthorized");
		_;
	}

	/** @dev Mapping that stores the tokenId for each requestId. If `requestId` is 0 for token under `id`, it means that the token can not be obtained via ZKP.
	 */
	mapping(uint256 => uint64) public tokenIdsToRequestIds;

	/**
	 * @dev Sets the request id for the token under `id`. Makes the token under `id` available for transfer via ZKP.
	 * @param _id uint256 ID of the token to be set for ZKP.
	 *
	 * Requirements:
	 *  - Caller must have minted the token under `id`.
	 */
	function setTransferRequestId(uint256 _id, uint64 _requestId) public onlyMinter(_id) {
		require(
			tokenIdsToRequestIds[_id] == 0,
			"ERC5516Verifier: Token under id already has a request id"
		);
		tokenIdsToRequestIds[_id] = _requestId;
	}

	mapping(uint256 => address) public idToAddress;
	mapping(address => uint256) public addressToId;

	function _beforeProofSubmit(
		uint64 /* requestId */,
		uint256[] memory inputs,
		ICircuitValidator validator
	) internal view override {
		// check that  challenge input is address of sender
		address addr = GenesisUtils.int256ToAddress(inputs[validator.getChallengeInputIndex()]);
		// this is linking between msg.sender and address in proof
		require(_msgSender() == addr, "address in proof is not a sender address");
	}

	function _afterProofSubmit(
		uint64 requestId,
		uint256[] memory inputs,
		ICircuitValidator validator
	) internal override {
		// we don't need to do anything, we have info that user provided proof to request id in proof[user][request] map;
	}

	/**
	 * @dev Asserts that _msgSender() has provided proof for the token under `id` and transfers the token to _msgSender().
	 */
	function assertProofSubmitted(uint256 id, uint64 requestId) external {
		// If request id is 0, it means that the token can not be obtained via ZKP.
		require(requestId != 0, "ERC5516Verifier: Request id can not be 0");
		// Require that the token under `id` has been set for ZKP with the same `requestId`.
		require(
			tokenIdsToRequestIds[id] == requestId,
			"ERC5516Verifier: Token under id is not set for this request id"
		);
		// Require that _msgSender() has provided proof for the token under `id`.
		require(
			proofs[_msgSender()][requestId] == true,
			"ERC5516Verifier: Proof was not submitted"
		);
		/**
		 * here we are using _safeTransferFrom from ERC5516, but can be replaced with any other function or action
		 * to be executed after proof is submitted.
		 */
		super._safeTransferFrom(
			LibERC5516.getTokenMinter(id),
			_msgSender(),
			id,
			TOKEN_AMOUNTS_PER_PROOF_SUBMISSION,
			""
		);
	}

	function _beforeTokenTransfer(
		address /* operator */,
		address /* from */,
		address to,
		uint256[] memory ids,
		uint256[] memory amounts,
		bytes memory /* data */
	) internal view override {
		require(amounts.length == 1, "ERC5516: Can only transfer one token");
		require(ids.length == 1, "ERC5516: Can only transfer one token");
		uint256 id = ids[0];
		uint64 requestId = tokenIdsToRequestIds[id];
		if (requestId != 0) {
			require(proofs[to][requestId] == true, "ERC5516Verifier: Proof was not submitted");
		}
	}

	function _beforeBatchedTokenTransfer(
		address /* operator */,
		address /* from */,
		address[] memory to,
		uint256 id,
		uint256 amount,
		bytes memory /* data */
	) internal virtual override {
		require(amount == 1, "ERC5516: Can only transfer one token");
		uint64 requestId = tokenIdsToRequestIds[id];
		if (requestId != 0) {
			require(proofs[to[0]][requestId] == true, "ERC5516Verifier: Proof was not submitted");
		}
	}
}
