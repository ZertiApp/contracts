//SPDX-License-Identifier: MIT

/**
 * @title Badge contract
 * @author Zerti Team - Matias Arazi
 * @notice Badge contract use for storing your badges as SBTs
 */
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Context.sol";

contract ZertiCollection is Context {

    struct Collection {
        address entity;
        string data;
    }

    mapping(uint256 => Collection) public collections;//id => Collection
    uint256 public nonce;

    /**
    * @param eventType equal to:
    * 0: is created a new collection
    * 1: is modified
    * 2: is deleted
    * @param id collections´s id
    * @param entity collections´s the one who created the collection
    * @param data the URI of the collection data
    */
    event collection(uint256 eventType, uint256 id, address entity, string data);

    function create(string calldata _data) external virtual{
        address minter = _msgSender();
        _create(minter, _data);
    }

    function _create(address _account, string calldata _data) internal virtual {
        collections[++nonce] = Collection(_account, _data);
        emit collection(0, nonce, _account, _data);
    }
}