---
eip: <to be assigned>
title: <SBT 1155>
description: <Semi-fungible SBT (SoulBourn Token)>
author: Matias Arazi ((@MatiArazi)[https://github.com/MatiArazi]), Lucas Grasso Ramos ((@LucasGrasso)[https://github.com/LucasGrasso]),
discussions-to: <URL>
status: Draft
type: <Standards Track, Meta, or Informational>
category (*only required for Standards Track): ERC
created: <date created on, in ISO 8601 (yyyy-mm-dd) format>
requires (*optional): 165, 1155
---

## Summary

## Abstract

Sbt
compatible erc1155
double sig
burnable

Abstract is a multi-sentence (short paragraph) technical summary. This should be a very terse and human-readable version of the specification section. Someone should be able to read only the abstract to get the gist of what this specification does.

## Motivation

nfts intransferibles dps initial transfer
no sbt approved with 1155
expanded by erc1155
esta sbt 721

porque es necesario


The motivation section should describe the "why" of this EIP. What problem does it solve? Why should someone want to implement this standard? What benefit does it provide to the Ethereum ecosystem? What use cases does this EIP address?



## Specification
The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in RFC 2119.

poner codigo de interfaz
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

The technical specification should describe the syntax and semantics of any new feature. The specification should be detailed enough to allow competing, interoperable implementations for any of the current Ethereum platforms (go-ethereum, parity, cpp-ethereum, ethereumj, ethereumjs, and [others](https://github.com/ethereum/wiki/wiki/Clients)).

## Rationale
porque el diseño
The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages.

## Backwards Compatibility
This proposal is fully backward compatible with EIP-1155.

## Test Cases
test.js
Test cases for an implementation are mandatory for EIPs that are affecting consensus changes.  If the test suite is too large to reasonably be included inline, then consider adding it as one or more files in `../assets/eip-####/`.

## Reference Implementation
dev
An optional section that contains a reference/example implementation that people can use to assist in understanding or implementing this specification.  If the implementation is too large to reasonably be included inline, then consider adding it as one or more files in `../assets/eip-####/`.

## Security Considerations
All EIPs must contain a section that discusses the security implications/considerations relevant to the proposed change. Include information that might be important for security discussions, surfaces risks and can be used throughout the life cycle of the proposal. E.g. include security-relevant design decisions, concerns, important discussions, implementation-specific guidance and pitfalls, an outline of threats and risks and how they are being addressed. EIP submissions missing the "Security Considerations" section will be rejected. An EIP cannot proceed to status "Final" without a Security Considerations discussion deemed sufficient by the reviewers.

## Copyright
Copyright and related rights waived via [CC0](../LICENSE.md).