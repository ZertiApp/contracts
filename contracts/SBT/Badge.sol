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

    // Used to store contracts created by each address
    mapping(address => uint256[]) internal _minterBalances;

    constructor(string memory _uri, string memory _name, string memory _symbol, string memory contractUri_) SBTERC1155(_uri) {
        name = _name;
        symbol = _symbol;
        _contractUri = contractUri_;
    }

    // Mints (creates a token)
    function mint(string memory data) external {
        if(keccak256(abi.encodePacked(data)) == keccak256("")) revert("Data is empty");
        address operator = _msgSender();
        _mint(operator, data);
        _minterBalances[operator].push(nonce);
    }

    // Burns (deletes a token)
    function burn(uint256 id) external {
        _burn(msg.sender, id);
    }

    /**
     * @dev See https://docs.opensea.io/docs/contract-level-metadata
     */
    function contractUri() public view returns(string memory) {
        return string(
                abi.encodePacked("https://ipfs.io/ipfs/", _contractUri)
            );
    }

    /**
     * @dev Retrieve ids of tokens minted by `account`

     * Requirements:
     *
     * - `account must be non-zero`
     *
     */
    function mintedBy(address account) external view returns(uint256[] memory) {
        if(account == address(0)) revert AddressZero();
        return _minterBalances[account];
    }

    /**
     * @dev Retrieve URIs of tokens minted by `account`

     * Requirements:
     *
     * - `account must be non-zero`
     *
     */
    function mintedByURIS(address account) external view returns(string[] memory) {
        if(account == address(0)) revert AddressZero();
        uint256[] memory _mintedTokens = _minterBalances[account];
        uint256 _nMintedTokens = _mintedTokens.length;
        string[] memory _mintedTokensURI = new string[] (_nMintedTokens);

        for(uint256 i = 0; i < _nMintedTokens;){
            _mintedTokensURI[i] = string(
                abi.encodePacked(_uri, tokens[_mintedTokens[i]].data)
            );
            unchecked {
                ++i;
            }
        }

        return _mintedTokensURI;
    }

}