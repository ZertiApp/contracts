//SPDX-License-Identifier: MIT

/**
 * @title Base Diamond Contract
 * @author Matias Arazi & Lucas Grasso Ramos
 */

pragma solidity ^0.8.4;

import "@solidstate/contracts/proxy/diamond/SolidStateDiamond.sol";

contract ZertiDiamond is SolidStateDiamond {
    constructor() SolidStateDiamond() {}
}