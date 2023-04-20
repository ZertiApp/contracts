// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC5516.sol";
import "./libraries/GenesisUtils.sol";
import "./interfaces/ICircuitValidator.sol";
import "./verifiers/ZKPVerifier.sol";

contract ERC5516Verifier is ERC5516, ZKPVerifier {
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

	/** @dev Mapping that stores the request id for each token id. If `requestId` is 0 for token under `id`, it means that the token can not be obtained via ZKP.
	 */
	mapping(uint64 => uint256) public requestIdsToTokenIds;
	uint64 internal transferRequestId = 1;

	/**
	 * @dev Sets the request id for the token under `id`. Makes the token under `id` available for transfer via ZKP.
	 * @param _id uint256 ID of the token to be set for ZKP.
	 *
	 * Requirements:
	 *  - Caller must have minted the token under `id`.
	 */
	function setTransferRequestId(uint256 _id) public onlyMinter(_id) {
		require(tokenIdsToRequestIds[_id] == 0, "Token under id already has a request id");
		tokenIdsToRequestIds[_id] = transferRequestId;
		transferRequestId++;
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
		// this is linking between msg.sender and
		require(_msgSender() == addr, "address in proof is not a sender address");
	}

	function _afterProofSubmit(
		uint64 requestId,
		uint256[] memory inputs,
		ICircuitValidator validator
	) internal override {
		require(
			tokenIdsToRequestIds[requestIdsToTokenIds[requestId]] == requestId &&
				addressToId[_msgSender()] == 0,
			"proof can not be submitted more than once"
		);

		// address didn't get airdrop tokens
		uint256 id = inputs[validator.getChallengeInputIndex()];
		// additional check didn't get airdrop tokens before
		if (idToAddress[id] == address(0)) {
			super._safeTransferFrom(address(this), _msgSender(), requestIdsToTokenIds[requestId], 1, "0x00");
			addressToId[_msgSender()] = id;
			idToAddress[id] = _msgSender();
		}
	}

	function _beforeTokenTransfer(
		address /* operator */,
		address /* from */,
		address to,
		uint256[] memory ids,
		uint256[] memory /* amounts */,
		bytes memory /* data */
	) internal view override {
		for (uint256 i = 0; i < ids.length; ) {
			uint256 id = ids[i];
			uint64 requestId = tokenIdsToRequestIds[id];
			if (requestIdsToTokenIds[requestId] == id) {
				require(
					proofs[to][requestId] == true,
					"only identities who provided proof are allowed to receive tokens"
				);
			}
			unchecked {
				++i;
			}
		}
	}

	function _beforeBatchedTokenTransfer(
		address /* operator */,
		address /* from */,
		address[] memory to,
		uint256 id,
		bytes memory /* data */
	) internal virtual override {
		uint64 requestId = tokenIdsToRequestIds[id];
		if (requestIdsToTokenIds[requestId] == id) {
			for (uint256 i = 0; i < to.length; ) {
				address _to = to[i];
				require(
					proofs[_to][requestId] == true,
					"only identities who provided proof are allowed to receive tokens"
				);
				unchecked {
					++i;
				}
			}
		}
	}
}
