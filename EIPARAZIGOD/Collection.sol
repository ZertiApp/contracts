//SPDX-License-Identifier: MIT

/**
 * @title Badge contract
 * @author Zerti Team - Matias Arazi, Lucas Grasso Ramos
 * @notice Collection contract for SBT tokens.
 */
pragma solidity ^0.8.4;

import "./@openzeppelin/Context.sol";

contract ZertiCollection is Context {

    struct Collection {
        address entity;
        string data;
    }

    mapping(uint256 => Collection) public collections; //id => Collection
    uint256 public collectionNonce;

    error Unauthorized(address account, uint256 id);

    modifier isOwner(address _account, uint256 _id) {
        if (_account != collections[_id].entity) revert Unauthorized(_account, _id);
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
    event CollectionUpdate(
        uint8 indexed eventType,
        address indexed entity,
        uint256 indexed id,
        string data
    );

    /**
     * @dev view function that gets the data from a specific collection
     * @param _id the id of a collection
     * @return string with the data from the collection with id equal to _id
     */
    function getData(uint256 _id) external view returns (string memory) {
        return collections[_id].data;
    }

    /**
     * @dev Get the creator(entity) of a specific collection
     *
     * @param _id the id of a collection
     * @return address of the entity that created collection under `_id`
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
    function _createCollection(address _account, string memory _data)
        internal
        virtual
    {
        collections[++collectionNonce] = Collection(_account, _data);
        emit CollectionUpdate(0, _account, collectionNonce, _data);
    }

    function modifyCollection(uint256 _id, string calldata _newData)
        external
        virtual
    {
        address account = _msgSender();
        _modifyCollection(account, _id, _newData);
    }

    /**
     * @dev modify a collection
     *
     * @param _account address of the entity modifing the collection.
     * @param _id the id of the collection to be modified
     * @param _newData new data of the collection.
     *
     * Emits a {CollectionUpdate-1} event
     *
     */
    function _modifyCollection(
        address _account,
        uint256 _id,
        string calldata _newData
    ) internal virtual isOwner(_account, _id) {
        collections[_id].data = _newData;
        emit CollectionUpdate(1, _account, _id, _newData);
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
    function _deleteCollection(address _account, uint256 _id)
        internal
        virtual
        isOwner(_account, _id)
    {
        emit CollectionUpdate(2, _account, _id, collections[_id].data);
        delete (collections[_id]);
    }
}
