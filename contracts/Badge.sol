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
    }

    mapping(uint256 => Badge) badges; //id to badge

    function mint(string calldata _name, string calldata _description, string calldata _image) external {
        idCount++;
        badges[idCount] = Badge(idCount, _name, _description, _image);
    }

    /* function receive() {

    }

    function burn(uint256 memory _id){
        badges[_id].
    } */

}
