//SPDX-License-Identifier: MIT

/**
 * @title Badge contract
 * @author Zerti Team - Matias Arazi
 * @notice Badge contract use for storing your badges as SBTs
 */
pragma solidity ^0.8.4;

import "hardhat/console.sol";

contract EIPARAZI {

    uint256 private nonce;
    mapping(uint256 => Zerti) public zerties; // id to Zerti
    mapping(uint256 => uint256) public amount; // the amounts of tokens for each Zerti
    mapping(address => mapping(uint256 => bool)) internal owners; // if owner has a specific Zerti
    mapping(address => mapping(uint256 => bool)) internal pending; // if owner has pending a specific Zerti
    mapping(address => bool) public validatedEntities;

    struct Zerti {
        address owner;
        string data;
    }

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
    
    //Function
    function mint(string calldata _data) external {
        /*
        if(!validatedEntities[msg.sender])
            //revert NotAnEntity(msg.sender); */
        _mint(_data);
    }

    function _mint(string memory _data) internal {
        zerties[++nonce] = Zerti(msg.sender, _data);
        amount[nonce] = 0;
        console.log("Zerti minted from %s, nonce: %s",msg.sender,nonce);
        emit ZertiMinted(msg.sender, nonce);
    }

    function transfer(uint256 _id, address[] calldata _to) external {
        if (zerties[_id].owner != msg.sender)
            revert Unauthorized(msg.sender);
        _transfer(_id, _to);
    }

    function _transfer(uint256 _id, address[] memory _to ) internal {
        for (uint256 i = 0; i < _to.length; ) {
            address dest = _to[i];
            if (owners[dest][_id] != false)
                revert AlreadyOwned(_id);
            if (pending[dest][_id] != false)
                revert AlreadyAwaitingClaim(_id);
            pending[dest][_id] = true;
            emit ZertiTransfer(msg.sender, dest, _id);
            unchecked {
                ++i;
            }
        }
    }

    function claim(uint256 _id) external {
        if (owners[msg.sender][_id] != false || pending[msg.sender][_id] != true)
            revert CanNotClaim(_id);
        _claim(_id);
    }

    function _claim(uint256 _id) internal {
        owners[msg.sender][_id] = true;
        pending[msg.sender][_id] = false;
        amount[_id]++;
        emit ZertiClaimed(msg.sender, _id);
    }

    function burn(uint256 _id) external {
        if(owners[msg.sender][_id] == true)
            revert Unauthorized(msg.sender);
        if(amount[_id] <= 0)
            revert CeroZertisIn(_id);
        _burn(_id);
    }

    function _burn(uint256 _id) internal {
        owners[msg.sender][_id] = false;
        amount[_id]--;
        emit ZertiBurned(msg.sender, _id);
    }

    //View
    function idInfo(uint256 _id) external view returns(address, string memory, uint256){
        return (zerties[_id].owner, zerties[_id].data, amount[_id]);
    }

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

}
