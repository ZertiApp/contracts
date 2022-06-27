//SPDX-License-Identifier: MIT

/**
 * @title Badge contract
 * @author Zerti Team - Matias Arazi
 * @notice Badge contract use for storing your badges as SBTs
 */
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Zerti {
    uint256 private nonce;
    struct Zerti {
        address owner;
        string data;
    }
    mapping(uint256 => Zerti) zerties;
    mapping(uint256 => uint256) amount;
    mapping(address => mapping(uint256 => bool)) owners;
    mapping(address => mapping(uint256 => bool)) pending;

    function mint(string data) public {
        zerties[++nonce] = Zerti(msg.sender, data);
        amount[nonce] = 0;
    }

    function transfer(uint256 memory id, address to[]) public {
        require(zerties[id].owner == msg.sender);
        for(int dest = 0; dest<to.size(); dest++){
            require(owners[id][dest] == false);
            require(pending[id][dest] == false);
            pending[dest] = id;
        }
    }

    function claim(uint memory id){
        require(owners[id][dest] == false);
        require(pending[id][dest] == true);
        amount[id]++;
        owners[msg.sender][id] = true;
        pending[msg.sender][id] = false;
    }

    function burn(uint256 memory id){
        require(owners[id][dest] == true);
        amount[id]--;
        owners[msg.sender][id] = false;
    }

    uint256 public constant ort = 1;
    uint256 public constant oma = 2;
    uint256 public constant launchpad = 3;
    uint256 public constant coderhouse = 4;

    constructor() ERC1155("test/BadgesJSON/{id}.json") {
        _mint(msg.sender, ort, 10**27, "");
        _mint(msg.sender, oma, 1, "");
        _mint(msg.sender, launchpad, 10**9, "");
        _mint(msg.sender, coderhouse, 10**9, "");
    }
}