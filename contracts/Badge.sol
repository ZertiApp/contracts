//SPDX-License-Identifier: MIT

/**
 * @title Token contract
 * @author Matias Arazi & Lucas Grasso Ramos
 * @notice MultiSig, Semi-Fungible, SoulBound Token standard for academic certification.
 */

pragma solidity ^0.8.4;

import "./ERC5516.sol";

contract Badge is ERC5516 {

    // Used as Name for the collection
    string public name;

    // Used as Symbol for the collection
    string public symbol;

    // Used as Contract Metadata URI
    string public _contractUri;

    constructor(string memory _uri, string memory _name, string memory _symbol, string memory contractUri_) ERC5516 (_uri) {
        name = _name;
        symbol = _symbol;
        _contractUri = contractUri_;
    }

    // Mints (creates a token)
    function mint(string memory data) external {
        if(keccak256(abi.encodePacked(data)) == keccak256("")) revert("Data is empty");
        _mint(msg.sender, data);
    }

    // Burns (deletes a token)
    function burn(uint256 id) external {
        _burn(msg.sender, id);
    }

    // Burns (deletes tokens)
    function burnBatch(uint256[] memory ids) external {
        _burnBatch(msg.sender, ids);
    }

    /**
     * @dev See https://docs.opensea.io/docs/contract-level-metadata
     */
    function contractUri() public view returns(string memory) {
        return string(
                abi.encodePacked("https://ipfs.io/ipfs/", _contractUri)
            );
    }

}