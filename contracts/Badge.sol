//SPDX-License-Identifier: MIT

/**
 * @title Badge contract
 * @author Zerti Team - Matias Arazi
 * @notice Badge contract use for storing your badges as SBTs
 */
pragma solidity ^0.8.4;


contract Zerti {
    uint256 private nonce;

    struct zerti {
        address owner;
        string data;
    }

    error Unauthorized(address _sender);
    error NotOwned();


    mapping(uint256 => zerti) zerties; // id to Zerti
    mapping(uint256 => uint256) amount;// the amounts of tokens for each Zerti
    mapping(address => mapping(uint256 => bool)) owners;// if owner has a specific Zerti
    mapping(address => mapping(uint256 => bool)) pending;// if owner has pending a specific Zerti

    
    function idInfo(uint id) external view returns(address, string memory){
        return (zerties[id].owner, zerties[id].data);
    }

    /*
    uint[] myzerti;
    function zertiesFrom(address from) external view returns(uint[] memory){
        myzerti = [];
        for(uint i = 1; i<=nonce; i++){
            if(owners[from][i]){
                myzerti.push(i);
            }
        }
        return myzerti;
    }
    */
    function mint(string calldata data) public {
        //requiere be entity
        zerties[++nonce] = zerti(msg.sender, data);
        amount[nonce] = 0;
    }

    function transfer(uint256 id, address[] memory to) public {
        if(zerties[id].owner != msg.sender) revert Unauthorized(msg.sender);
        for(uint i = 0; i<to.length;){
            address dest = to[i];
            if(owners[dest][id] != false || pending[dest][id] )
            require(owners[dest][id] == false);
            require(pending[dest][id] == false);
            pending[dest][id] = true;
            unchecked{
                ++i;
            }
        }
    }

    function claim(uint id) public{
        require(owners[msg.sender][id] == false);
        require(pending[msg.sender][id] == true);
        owners[msg.sender][id] = true;
        pending[msg.sender][id] = false;
        amount[id]++;
    }

    function burn(uint256 id) public{
        require(owners[msg.sender][id] == true);
        owners[msg.sender][id] = false;
        amount[id]--;

    }
}