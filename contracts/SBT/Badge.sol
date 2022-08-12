//SPDX-License-Identifier: MIT

/**
 * @title Token contract
 * @author Matias Arazi & Lucas Grasso Ramos
 * @notice MultiSig, Semi-Fungible, SoulBound Token standard for academic certification.
 */

pragma solidity ^0.8.4;

import "./SBTERC1155.sol";

contract Badge is SBTERC1155 {

    // Used as Name for the collection
    string public name;

    // Used as Symbol for the collection
    string public symbol;

    // Used as Contract Metadata URI
    string public _contractUri;

    constructor(string memory _uri, string memory _name, string memory _symbol, string memory contractUri_) SBTERC1155(_uri) {
        name = _name;
        symbol = _symbol;
        _contractUri = contractUri_;
    }

    // Mints (creates a token)
    function mint(string memory data) external {
        _mint(msg.sender, data);
    }

    // Burns (deletes a token)
    function burn(uint256 id) external {
        _burn(msg.sender, id);
    }

    function contractUri() public view returns(string memory) {
        return string(
                abi.encodePacked("https://ipfs.io/ipfs/", _contractUri)
            );
    }

}