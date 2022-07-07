//SPDX-License-Identifier: MIT

/**
 * @title Badge contract
 * @author Zerti Team - Matias Arazi
 * @notice Badge contract use for storing your badges as SBTs
 */
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "./SBT/ISBTDoubleSig.sol";
import "./SBT/SBTDoubleSig.sol";
import "./IVF.sol";
import "./Collection.sol";

contract Badge is SBTDoubleSig, ZertiCollection{


    address internal voteFactory;
   
    mapping(uint256 => uint256)public badge_collection; //BadgeId => CollectionId
    

    error NotAnEntity(address _sender);

    constructor(string memory _uri) SBTDoubleSig(_uri) {
        _mint(msg.sender, _uri);
    }

    function _beforeTokenTransfer(address _from, address _to, uint256 _id, uint256 _amount) internal view override{
        if(_from == address(0)) { //MINTING
            if(!IVF(voteFactory).isEntity(msg.sender))
                revert NotAnEntity(msg.sender);
        }
    }

}