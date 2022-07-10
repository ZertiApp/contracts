//SPDX-License-Identifier: MIT

/**
 * @title Badge contract
 * @author Zerti Team - Matias Arazi
 * @notice Badge contract use for storing your badges as SBTs
 */
pragma solidity ^0.8.4;

import "./SBT/ISBTDS.sol";
import "./SBT/SBTDS.sol";
import "./IVF.sol";
import "./Collection.sol";

contract Badge is SBTDS, ZertiCollection{

    address internal voteFactory;
   
    mapping(uint256 => uint256) public badgeCollection; //BadgeId => CollectionId
    

    error NotAnEntity(address _sender);

    constructor(string memory _uri) SBTDS(_uri) {
        _mint(msg.sender, _uri);
    }

    /**
     * @dev see {SBTDoubleSig-_mint}
     */
     function mint(string memory _data) external {
        if(!IVF(voteFactory).isEntity(msg.sender))
                revert NotAnEntity(msg.sender);
        _mint(msg.sender, _data);
     }

}