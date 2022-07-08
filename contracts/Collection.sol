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

    error NotOwner(address account, uint256 id);

    modifier beOwner(address _account, uint256 _id){
        if(_account != collections[_id].entity){
            revert(NotOwner(_account, _id));
        }
        _;
    }

    /** 
    * @param eventType equal to:
    * 0: is created a new collection
    * 1: is modified
    * 2: is deleted
    * @param id collections´s id
    * @param entity collections´s the one who created the collection
    * @param data the URI of the collection data
    */
    event Collection(uint256 eventType, uint256 id, address entity, string data);

    /**
    * @dev view function that gets the data from a specific collection
    * @param _id the id of a collection
    * @return a string with the data from the collection with id equal to _id
    */
    function getData(uint256 _id) external view{
        returns collections[_id].data;
    }

    /**
    * @dev view function that gets the entity from a specific collection
    * @param _id the id of a collection
    * @return an address with the entity from the collection with id equal to _id
    */
    function getEntity() external view{
        returns collections[_id].entity;
    }

    function create(string calldata _data) external virtual{
        address minter = _msgSender();
        _create(minter, _data);
    }

    /**
     * @dev: create a collection
     * @param _account address of the entity creating the collection.
     * @param _data data of the collection.
     * Emits a {Collection} event
     *
     */
    function _create(address _account, string calldata _data) internal virtual {
        collections[++nonce] = Collection(_account, _data);
        emit Collection(0, nonce, _account, _data);
    }

    function modify(uint256 _id, string calldata _data) external virtual {
        address minter = _msgSender();
        _modify(minter, _data);
    }

        /**
     * @dev: modifies a collection
     * @param _account address of the entity modifing the collection.
     * @param _id the id of the collection to be modified
     * @param _data new data of the collection.
     * Emits a {Collection} event
     *
     */
    function _modify(address _account, uint256 _id, string calldata _data) internal virtual beOwner{
        collections[_id].data = _data;
        emit Collection(1, _id, _account, _data);

    }

    function delete uint256 _id) external virtual{
        address minter = _msgSender();
        _create(minter, _data);
    }

    /**
     * @dev: delete a collection
     * @param _account address of the entity deleting the collection.
     * @param _id id of the collection.
     * Emits a {Collection} event
     *
     */
    function _delete(address _account,  uint256 _id) internal virtual beOwner{
        emit Collection(2, _id, _account, collections[_id].data);
        delete(collections[_id]);
    }


}