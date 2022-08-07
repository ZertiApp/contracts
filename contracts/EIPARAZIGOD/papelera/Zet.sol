// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Zet is ERC20 {
    constructor() ERC20("Zet", "ZET") {
        _mint(msg.sender, 250000000 * 10 ** decimals());
    }
}
