---
eip: <to be assigned>
title: Soulbound, Multi-Token, Semi-fungible, Double-Signature Standard.
description: An interface for non-transferrable NFTs binding to an Ethereum account for standardized blockchain-based academic certification.
author: Matias Arazi <matiasarazi@gmail.com>, Lucas Martín Grasso Ramos<lucasgrassoramos@gmail.com>
discussions-to: <URL>
status: Draft
type: Standards Track
category (*only required for Standards Track): ERC
created: 2022-08-19
requires (*optional): 165, 1155
---

## Abstract

This is a standard interface for non fungible, double signature, multi-token, Soulbound Token standard. It was inspired by the main characteristics of the EIP-1155 token and by the [article](https://vitalik.ca/general/2022/01/26/soulbound.html) and [paper](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4105763) published by Vitalik Butherin, both texts presented benefits and potential use-cases of SoulBoundTokens(SBT).

## Motivation

We found a potential problem, the lack of credibility and faithfulness in online certifications, and imagined a solution, inspired by the everyday more common articles and mentions of Soulbound Tokens. We set to combine the best characteristics of each standardized EIP with the sole objective of elaborating a solid and useful token standard.

### Characteristics
* The NFT will be nontransferable after the initial transfer(SoulBoundToken-SBT).
* Is backwards compatible with EIP-1155.
* Double Signature.
* Multi-Token.
* Semi-Fungible standard.

### Applications
* Academy
* Certifications
* Smart Contract certifications(Code auditories)
* POAP
* And more

## Specification
The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in RFC 2119.

Smart contracts implementing the SBTERC1155DS standard MUST implement all of the functions in the SBTERC1155DS interface.

Smart contracts implementing the SBTERC1155DS standard MUST implement the ERC-165 supportsInterface function and and MUST return the constant value true if 0x812b9fae is passed through the interfaceID argument.They also MUST implement the EIP-1155 Interface and MUST return the constant value true if 0xd9b67a26 is passed through the interfaceID argument. Furthermore, they MUST implement the EIP-1155 Metadata interface, and MUST return the constant value true if 0x0e89341c is passed through the interfaceID argument.

See [EIP-1155 Specification](https://eips.ethereum.org/EIPS/eip-1155#specification)

__The approval methods were overridden and emptied for allowing only token receivers to have full control over their tokens.__


```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @dev Interface of the SBTERC1155 Contract
 */
interface ISBTERC1155DS {

    /**
     * @dev Emitted when `newOwner` claims or rejects pending `id`.
     */
    event TokenClaimed(address indexed operator, address indexed newOwner, uint256 id);

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
```

## Rationale

### Soulbound/Account Bound
The token was designed as Soulbound in order to it being nontransferable. This is because the type of problem this standard aims to solve requires this non-transferability.

### Double-Signature
The Double-Signature functionality was implemented to prevent the receival of unwanted tokens. As this standard is aimed to academic certification, this functionality mimics the real world: You have to accept a degree for it to be yours, for example.

### Only transferable by token creator/minter
As the problem this standard aims to solve is academic certification, this characteristic also tends to mimic real world functionality. Only the creator/minter of the token under `id` will be able to transfer the token to new people (Semi-Fungible token). This allows for issuer traceability and connections with a DAO Voting System, for example, in order to only allow emission to voted and trusted addresses. Regardless of this, users have full power over their tokens: They can claim/reject them, and burn them afterwards. Token creators/minters have no control over a token after minting.

### Metadata & Multi-token.
The EIP1155 Metadata Interface was implemented for more compatibility with EIP-1155. Despite this, the standard only stores the base URI (For example, "https://ipfs.io/ipfs/") and saves the IPFS Hash for each id (Example: "QmeHSRgayHELM7gJSFzc3cFRU9Vx1KYQdK2BHy5vpTF7uT"). When `uri(...)` function is called, these two strings are concatenated to generate a unique metadata under each token id, allowing for a multi-token standard. The multi-token functionality was used in order for easier organization, all emitted tokens are stored in the same contract, preventing redundant bytecode from being deployed to the blockchain. It also facilitates transfer to token issuers.

See [EIP-1155 Metadata](https://eips.ethereum.org/EIPS/eip-1155#metadata)

### Multi Transfer 
The token standard supports a transfer function to multiple addresses, and this was made to ease the transfer to multiple people, making it more gas-efficient and easier for the users.

## Backwards Compatibility
This proposal is fully backward compatible with EIP-1155.

## Reference Implementation
The reference implementation of this interface can be found at  []()

## Security Considerations
There are no security considerations related directly to the implementation of this standard.

## References

**Standards**
* [EIP-1155 Multi Token Standard](https://eips.ethereum.org/EIPS/eip-1155)
* [EIP-165 Standard Interface Detection](https://eips.ethereum.org/EIPS/eip-165)
* [JSON Schema](https://json-schema.org/)
* [RFC 2119 Key words for use in RFCs to Indicate Requirement Levels](https://www.ietf.org/rfc/rfc2119.txt)

**Implementations**
* [Zerti](https://dev.zerti.com.ar/feed) (Link to Rinkeby testnet test application)

**Articles & Discussions**
* [Decentralized Society: Finding Web3's Soul](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4105763)
* [Soulbound](https://vitalik.ca/general/2022/01/26/soulbound.html)

## Copyright
Copyright and related rights waived via [CC0](../LICENSE.md).