// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC5516.sol";
import "./libraries/GenesisUtils.sol";
import "./interfaces/ICircuitValidator.sol";
import "./verifiers/ZKPVerifier.sol";

contract ERC5516Verifier is ERC5516, ZKPVerifier {
	uint64 public constant TRANSFER_REQUEST_ID = 1;

	mapping(uint256 => address) public idToAddress;
	mapping(address => uint256) public addressToId;

	uint256 public TOKEN_AMOUNT_FOR_AIRDROP_PER_ID = 1;

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
			requestId == TRANSFER_REQUEST_ID && addressToId[_msgSender()] == 0,
			"proof can not be submitted more than once"
		);

		// address didn't get airdrop tokens
		uint256 id = inputs[validator.getChallengeInputIndex()];
		// additional check didn't get airdrop tokens before
		if (idToAddress[id] == address(0)) {
			super._safeTransferFrom(address(this), _msgSender(), id, 1, "0x00");
			addressToId[_msgSender()] = id;
			idToAddress[id] = _msgSender();
		}
	}

	function _beforeTokenTransfer(
		address /* operator */,
		address /* from */,
		address to,
		uint256[] memory /* ids */,
		uint256[] memory /* amounts */,
		bytes memory /* data */
	) internal view override {
		require(
			proofs[to][TRANSFER_REQUEST_ID] == true,
			"only identities who provided proof are allowed to receive tokens"
		);
	}

	function _beforeBatchedTokenTransfer(
		address /* operator */,
		address /* from */,
		address[] memory to,
		uint256 /* id */,
		bytes memory /* data */
	) internal virtual override {
		for (uint256 i = 0; i < to.length; ) {
			address _to = to[i];
			require(
				proofs[_to][TRANSFER_REQUEST_ID] == true,
				"only identities who provided proof are allowed to receive tokens"
			);
			unchecked {
				++i;
			}
		}
	}
}
