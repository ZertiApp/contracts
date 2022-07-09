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
    function _mint(address _account, string memory _data) internal override {
        if(!IVF(voteFactory).isEntity(_account))
                revert NotAnEntity(msg.sender);
        unchecked {
            ++nonce;
        }
        tokens[nonce] = Token(_account, _data);
        amount[nonce] = 0;
        _createCollection(_account, _data);
        emit TokenTransfer(address(0), msg.sender, nonce);
    }

}