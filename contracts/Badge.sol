//SPDX-License-Identifier: MIT

/**
 * @title Badge contract
 * @author Zerti Team - Matias Arazi & Lucas Grasso Ramos
 * @notice Badge contract use for storing your badges as SBTs
 */
pragma solidity ^0.8.4;

import "./SBT/ISBTDS.sol";
import "./SBT/SBTDS.sol";
import "./IVF.sol";

contract BadgeZerti is SBTDS {

    address public immutable voteFactory;

    error NotAnEntity(address _sender);

    constructor(string memory _uri, address _voteFactory) SBTDS(_uri) {
        voteFactory = _voteFactory;
    }

    /**
     * @dev see {SBTDoubleSig-_mint}
     */
    function mint(string memory _data) external {
        address account = _msgSender();
        _mint(account, _data);
    }

    /**
     * @dev see {SBTDoubleSig-_mint}
     */
    function entityMintTest(string memory _data) external {
        if(!IVF(voteFactory).isEntity(msg.sender))
                revert NotAnEntity(msg.sender);
        _mint(msg.sender, _data);
    }

    function transfer(
        uint256 _id,
        address _to,
        string memory _newData
    ) external {
        address from = _msgSender();
        _transfer(from, _id, _to);
        tokens[_id].data = _newData;
    }

    function transferBatch(
        uint256 _id,
        address[] memory _to,
        string memory _newData
    ) external {
        address from = _msgSender();
        _transferBatch(from, _id, _to);
        tokens[_id].data = _newData;
    }

}
