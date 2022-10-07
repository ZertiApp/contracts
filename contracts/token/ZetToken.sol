// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20/ERC20.sol";
import "./ERC20/ERC20Burnable.sol";

contract ZetToken is ERC20, ERC20Burnable {
    constructor() ERC20("Zets", "ZET") {
         _mint(msg.sender, 250000000 * 10 ** decimals());
    }
}
