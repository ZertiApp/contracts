---
eip: <to be assigned>
title: Multi-Token, Semi-fungible, Double-Signature, Soulbound Token Standard(SBTERC1155DS)
description: Token proposal for standarized blockchain-based academic certification.
author: Matias Arazi <matiasarazi@gmail.com>, Lucas Martín Grasso Ramos<lucasgrassoramos@gmail.com>
discussions-to: <URL>
status: Draft
type: Standards Track
category (*only required for Standards Track): ERC
created: 2022-08-19
requires (*optional): 165, 1155
---

## Abstract

This is a standard interface for non fungible, double signature, multi-token, Soulbound Token standard. It was inspired by the main characteristics of the EIP-1155 token and by the [article](https://vitalik.ca/general/2022/01/26/soulbound.html) published by Vitalik Butherin that presented benefits and potential use-cases of SoulBoundTokens(SBT).

## Motivation

We found a potential problem, the lack of credibility and faithfulness in online certifications, and imagined a solution, inspired by the everyday more common articles and mentions of Soulbound Tokens. We set to combine the best characteristics of each standarized EIP with the sole objective of elaborating a solid and useful token standard.

### Characteristcs
* The NFT will be intransferible after the initial transfer(SoulBoundToken-SBT).
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

Smart contracts implementing the SBTERC1155DS standard MUST implement the ERC-165 supportsInterface function and MUST return the constant value true if 0xd9b67a26 is passed through the interfaceID argument. They also MUST implement the ERC1155 Metadata interface, and MUST return the constant value true if 0x0e89341c is passed through the interfaceID argument.


```solidity
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

/**
 * @dev Interface of the SBTERC1155 Contract
 */
interface ISBTERC1155 {

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

EXPLICAR PORQUE CADA COSA

The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current Ethereum platforms (go-ethereum, parity, cpp-ethereum, ethereumj, ethereumjs, and [others](https://github.com/ethereum/wiki/wiki/Clients)).

## Rationale

### Soulbound
The token was designed as Soulbound in order to it being intransferible. This is because the type of problem this standard aims to solve requires this intransferability.

### Double-Signature
The Double-Signature functionality was implemented to prevent the receival of unwanted tokens. As this standard is aimed to academic certification, this functionality mimics the real world: You have to accept a degree for it to be yours, for example.

### Multi-Token

### Metadata
The EIP1155 Metadata Interface was implemented for more compatibility with EIP-1155.

### Multi Transfer 
The token standard supports a transfer function to multiple addresses, and this was made to ease the transfer to multiple people, making it more gas-efficient and easier for the users.

porque el diseño

We implement the double sig function to prevent the spam or unwanted tokens. We thought the user has to claimed the token they want or reject it in the other case.

The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages.

## Backwards Compatibility
This proposal is fully backward compatible with EIP-1155.

## Reference Implementation
This standard proposal is currently being used by the Zerti app. You can access the test app [here](https://dev.zerti.com.ar/) (Rinkeby testnet).

## Security Considerations
All EIPs must contain a section that discusses the security implications/considerations relevant to the proposed change. Include information that might be important for security discussions, surfaces risks and can be used throughout the life cycle of the proposal. E.g. include security-relevant design decisions, concerns, important discussions, implementation-specific guidance and pitfalls, an outline of threats and risks and how they are being addressed. EIP submissions missing the "Security Considerations" section will be rejected. An EIP cannot proceed to status "Final" without a Security Considerations discussion deemed sufficient by the reviewers.

## Copyright
Copyright and related rights waived via [CC0](../LICENSE.md).