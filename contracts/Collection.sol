//SPDX-License-Identifier: MIT

/**
 * @title Badge contract
 * @author Zerti Team - Matias Arazi, Lucas Grasso Ramos
 * @notice Collection contract for SBT tokens.
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

    modifier isOwner(address _account, uint256 _id){
        if(_account != collections[_id].entity)
            revert NotOwner(_account, _id);
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
    event CollectionUpdate(uint8 eventType, address entity, uint256 id, string data);

    /**
    * @dev view function that gets the data from a specific collection
    * @param _id the id of a collection
    * @return a string with the data from the collection with id equal to _id
    */
    function getData(uint256 _id) external view returns(string memory) {
        return collections[_id].data;
    }

    /**
     * @dev Get the creator(entity) of a specific collection
     *
     * @param _id the id of a collection
     * @return an address with the entity from the collection with id equal to _id
     *
     */
    function getEntity(uint256 _id) external view returns (address) {
        return collections[_id].entity;
    }

    /**
     * @dev create a collection
     *
     * @param _account address of the entity creating the collection.
     * @param _data data of the collection.
     *
     * Emits a {CollectionUpdate-0} event
     *
     */
    function _createCollection(address _account, string memory _data) internal virtual {
        collections[++nonce] = Collection(_account, _data);
        emit CollectionUpdate(0, _account, nonce, _data);
    }

    function modifyCollection (uint256 _id, string calldata _data) external virtual {
        address account = _msgSender();
        _modifyCollection(account, _id, _data);
    }

    /**
     * @dev modify a collection
     *
     * @param _account address of the entity modifing the collection.
     * @param _id the id of the collection to be modified
     * @param _data new data of the collection.
     *
     * Emits a {CollectionUpdate-1} event
     *
     */
    function _modifyCollection(address _account, uint256 _id, string calldata _data) internal virtual isOwner(_account, _id) {
        collections[_id].data = _data;
        emit CollectionUpdate(1,  _account, _id, _data);
    }

    function deleteCollection(uint256 _id) external virtual {
        address account = _msgSender();
        _deleteCollection(account, _id);
    }

    /**
     * @dev delete a collection
     *
     * @param _account address of the entity deleting the collection.
     * @param _id id of the collection.
     *
     * Emits a {CollectionUpdate-2} event
     *
     */
    function _deleteCollection(address _account,  uint256 _id) internal virtual isOwner(_account, _id) {
        emit CollectionUpdate(2, _account, _id, collections[_id].data);
        delete(collections[_id]);
    }


}