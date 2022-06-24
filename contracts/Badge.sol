//SPDX-License-Identifier: MIT

/**
 * @title Badge contract
 * @author Zerti Team - Matias Arazi
 * @notice Badge contract use for storing your badges as SBTs
 */
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Badge is ERC1155 {
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