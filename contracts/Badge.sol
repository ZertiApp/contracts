//SPDX-License-Identifier: MIT

/**
 * @title Badge contract
 * @author Zerti Team - Matias Arazi
 * @notice Badge contract use for storing your badges as SBTs
 */
pragma solidity ^0.8.4;

import "hardhat/console.sol";

contract EIPARAZI {

    struct Zerti {
        address owner;
        string data;
    }

    uint256 private nonce;
    mapping(uint256 => Zerti) public zerties; // id to Zerti
    mapping(uint256 => uint256) public amount; // the amounts of tokens for each Zerti
    mapping(address => mapping(uint256 => bool)) internal owners; // if owner has a specific Zerti
    mapping(address => mapping(uint256 => bool)) internal pending; // if owner has pending a specific Zerti
    mapping(address => bool) public validatedEntities;

    error Unauthorized(address _sender);
    error AlreadyOwned(uint256 _id);
    error AlreadyAwaitingClaim(uint256 _id);
    error CanNotClaim(uint256 _id);
    error NotAnEntity(address _sender);
    error CeroZertisIn(uint256 _id);

    event ZertiMinted(
        address _entity,
        uint256 _id
    );

    event ZertiTransfer(
        address _from,
        address _to,
        uint256 _id
    );

    event ZertiClaimed(
        address _newOwner,
        uint256 _id
    );

    event ZertiBurned(
        address _owner,
        uint256 _id
    );

    //View
    /**
    * @dev gets the entity of a zerti
    * @param _id the id of the zerti
    * @return the address of the owner
    */
    function ownerOf(uint256 _id) external view returns(address){
        return (zerties[_id].owner);
    }

    /**
    * @dev gets the uri of a zerti
    * @param _id the id of the zerti
    * @return the uri of the zerti
    */
    function uriOf(uint256 _id) external view returns(string memory){
        return (zerties[_id].data);
    }
    /**
    * @dev gets the amount of a zerti
    * @param _id the id of the zerti
    * @return the amount of the zerti
    */
    function amountOf(uint256 _id) external view returns(uint256){
        return (amount[_id]);
    }

    /**
    * @dev gets the zertis of an address
    * @param _from an address
    * @return the zertis that _from has
    */
    function zertiesFrom(address _from) external view returns(uint256[] memory){
        uint256 _tokenCount = 0;
        for(uint256 i = 1; i<= nonce;){
            if(owners[_from][i]){
                unchecked{
                    ++_tokenCount;
                }         
            }
            unchecked{
                ++i;
            }
        }
        uint256[] memory _myZerties = new uint256[](_tokenCount);
         for(uint i = 1; i<=nonce;){
            if(owners[_from][i]){
                _myZerties[--_tokenCount] = i;
            }
            unchecked{
                ++i;
            }
        }
        return _myZerties;
    }

    function pendingFrom(address _from) external view returns(uint256[] memory){
        uint256 _tokenCount = 0;
        for(uint256 i = 1; i<=nonce;){
            if(pending[_from][i]){
                ++_tokenCount;
            }
            unchecked{
                ++i;
            }
        }
        uint256[] memory _myZerties = new uint256[](_tokenCount);
            for(uint256 i = 1; i<=nonce;){
            if(pending[_from][i]){
                _myZerties[--_tokenCount] = i;
            }
            unchecked {
                ++i;
            }
        }
        return _myZerties;
    }

    
    //Function
    /**
     * @dev entity mints a zerti
     * @param _data URI from the zerti
     */
    function mint(string calldata _data) external {
        /*
        if(!validatedEntities[msg.sender])
            //revert NotAnEntity(msg.sender); */
        address minter = msg.sender;
        _mint(minter, _data);
    }

    function _mint(address _account, string memory _data) internal {
        zerties[++nonce] = Zerti(_account, _data);
        amount[nonce] = 0;
        console.log("Zerti minted from %s, nonce: %s",_account,nonce);
        emit ZertiMinted(_account, nonce);
    }

    /**
     * @dev mint a zerti
     * @param _id the zerti id
`````* @param _to the addresses that will be transfer the zerti
     */
    function transfer(uint256 _id, address[] calldata _to) external {
        address account = msg.sender;
        if (zerties[_id].owner != account)
            revert Unauthorized(account);
        _transfer(account, _id, _to);
    }

    function _transfer(address _from, uint256 _id, address[] memory _to ) internal {
        for (uint256 i = 0; i < _to.length; ) {
            address dest = _to[i];
            if (owners[dest][_id] != false)
                revert AlreadyOwned(_id);
            if (pending[dest][_id] != false)
                revert AlreadyAwaitingClaim(_id);
            pending[dest][_id] = true;
            emit ZertiTransfer(_from, dest, _id);
            unchecked {
                ++i;
            }
        }
    }
    /**
     * @dev user claims a zerti
     * @param _id the zerti id
     */
    function claim(uint256 _id) external {
        address account = msg.sender;
        if (owners[account][_id] != false || pending[account][_id] != true)
            revert CanNotClaim(_id);
        _claim(account, _id);
    }

    function _claim(address _account, uint256 _id) internal {
        owners[_account][_id] = true;
        pending[_account][_id] = false;
        amount[_id]++;
        emit ZertiClaimed(_account, _id);
    }
    /**
     * @dev owner of zerti burns it
     * @param _id the zerti id
     */
    function burn(uint256 _id) external {
        address account = msg.sender;
        if(owners[account][_id] == true)
            revert Unauthorized(account);
        if(amount[_id] <= 0)
            revert CeroZertisIn(_id);
        _burn(account, _id);
    }

    function _burn(address _account, uint256 _id) internal {
        owners[_account][_id] = false;
        amount[_id]--;
        emit ZertiBurned(_account, _id);
    }

    
}
