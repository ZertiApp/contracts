//SPDX-License-Identifier: MIT

/**
 * @title Badge contract
 * @author Zerti Team - Matias Arazi
 * @notice Badge contract use for storing your badges as SBTs
 */
pragma solidity ^0.8.4;

contract Badges {
    uint256 idCount = 0;
    struct Badge{
        uint256 id;
        string name;
        string description;
        string image;
        address owner;
    }

    mapping(uint256 => Badge) badges; //id to badge
    mapping(uint => address) balance; 

    function mint(string calldata _name, string calldata _description, string calldata _image) external {
        idCount++;
        badges[idCount] = Badge(idCount, _name, _description, _image, msg.sender);
    }

    function transferFrom(address[] _to,  uint _id) public{
        require(msg.sender == badges[_id].owner);
        for(int i = 0; i<from.lenght(), i++){
            
        }
    }

    /* function receive() {

    }

    function burn(uint256 memory _id){
        badges[_id].
    } */

}
