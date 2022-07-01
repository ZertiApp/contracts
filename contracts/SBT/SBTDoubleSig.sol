//SPDX-License-Identifier: MIT

/**
 * @title Token contract
 * @author Matias Arazi & Lucas Grasso Ramos
 * @notice MultiSig, Semi-Fungible, SoulBound Token standard for academic certification.
 */

pragma solidity ^0.8.4;

import "./ISBTDoubleSig.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract SBTDoubleSig is Context,ERC165, ISBTDoubleSig {

    uint256 private nonce;
    mapping(uint256 => Token) public tokens; // id to Token
    mapping(uint256 => uint256) public amount; // the amounts of tokens for each Token
    mapping(address => mapping(uint256 => bool)) public balanceOf; // if owner has a specific Token
    mapping(address => mapping(uint256 => bool)) public pending; // if owner has pending a specific Token

    struct Token {
        address owner;
        string data;
    }
    
    error NotOwner(address _sender);
    error AlreadyOwned(address _account, uint256 _id);
    error AlreadyPending(address _account, uint256 _id);
    error CanNotClaim(address _account, uint256 _id);

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(SBTDoubleSig).interfaceId;
            super.supportsInterface(interfaceId);
    }

    function ownerOf(uint256 _id) external view virtual override returns(address) {
        return (tokens[_id].owner);
    }
    function uriOf(uint256 _id) external view virtual override returns(string memory){
        return (tokens[_id].data);
    }
    function amountOf(uint256 _id) external view virtual override returns(uint256){
        return (amount[_id]);
    }
    function tokensFrom(address _from) external view virtual override returns(uint256[] memory) {
        uint256 _tokenCount = 0;
        for(uint256 i = 1; i<= nonce;){
            if(balanceOf[_from][i]){
                unchecked{
                    ++_tokenCount;
                }         
            }
            unchecked{
                ++i;
            }
        }
        uint256[] memory _ownedTokens = new uint256[](_tokenCount);
         for(uint i = 1; i<=nonce;){
            if(balanceOf[_from][i]){
                _ownedTokens[--_tokenCount] = i;
            }
            unchecked{
                ++i;
            }
        }
        return _ownedTokens;
    }

    function pendingFrom(address _from) external view virtual override returns(uint256[] memory){
        uint256 _tokenCount = 0;
        for(uint256 i = 1; i<=nonce;){
            if(pending[_from][i]){
                ++_tokenCount;
            }
            unchecked{
                ++i;
            }
        }
        uint256[] memory _pendingTokens = new uint256[](_tokenCount);
            for(uint256 i = 1; i<=nonce;){
            if(pending[_from][i]){
                _pendingTokens[--_tokenCount] = i;
            }
            unchecked {
                ++i;
            }
        }
        return _pendingTokens;
    }


    /** 
    *@dev mints a token
    *@param _data the uri of the token
    */
    function mint(string calldata _data) external virtual {
        address minter = _msgSender();
        _mint(minter, _data);
    }

    /**
    *@dev mints a token
    *@param _account address who will mint the token
    *@param _data the uri of the token
    */
    function _mint(address _account, string memory _data) internal virtual {
        unchecked{++nonce;}
        _beforeTokenTransfer(address(0),_account, nonce, 0);
        tokens[nonce] = Token(_account, _data);
        amount[nonce] = 0;
        emit TokenTransfer(0,msg.sender, nonce);
        _afterTokenTransfer(address(0),_account, nonce, 0);
    }

    function transfer(uint256 _id, address _to) external virtual override returns(bool) {
        address from = _msgSender();
        _transfer(from, _id, _to);
        return true;
    }

    function _transfer(address _from, uint256 _id, address _to ) internal virtual {
        if (tokens[_id].owner != _from)
            revert NotOwner(_from);
        if (balanceOf[_to][_id] != false)
            revert AlreadyOwned(_to, _id);
        if (pending[_to][_id] != false)
            revert AlreadyPending(_to, _id);
        _beforeTokenTransfer(_from, _to, nonce, 1);
        pending[_to][_id] = true;
        _afterTokenTransfer(_from, _to, nonce, 1);
        emit TokenTransfer(_from, _to, _id);
    }
    
    function transferBatch(uint256 _id, address[] calldata _to) external virtual override returns(bool) {
        address from = _msgSender();
        _transferBatch(from, _id, _to);
        return true;
    }

    function _transferBatch(address _from, uint256 _id, address[] memory _to ) internal virtual {
        if (tokens[_id].owner != _from)
            revert NotOwner(_from);
            
        for (uint256 i = 0; i < _to.length; ) {
            address _dest = _to[i];
            if (balanceOf[_dest][_id] != false)
                revert AlreadyOwned(_dest, _id);
            if (pending[_dest][_id] != false)
                revert AlreadyPending(_dest, _id);
            _transfer(_from, _id, _dest);
            unchecked {
                ++i;
            }
        }
    }

    function claim(uint256 _id) external virtual {
        address claimer = _msgSender();
        _claim(claimer, _id);
    }

    function _claim(address account, uint256 _id) internal virtual {
        if (balanceOf[account][_id] != false || pending[account][_id] != true)
            revert CanNotClaim(_id);

        _beforeTokenClaim(account, _id);
        balanceOf[account][_id] = true;
        pending[account][_id] = false;
        amount[_id]++;
        emit TokenClaimed(account, true, _id);
        _afterTokenClaim(account, _id);
    }

    function reject(uint256 _id) external virtual {
        address _account = _msgSender();
        _reject(_account, _id);
    }

    function _reject(address _account, uint256 _id) internal virtual {
        if (balanceOf[_account][_id] != false || pending[_account][_id] != true)
            revert CanNotClaim(_account,_id);

        _beforeTokenClaim(address(0), _id);
        balanceOf[_account][_id] = false;
        pending[_account][_id] = false;
        emit TokenClaimed(address(0), _id);
        _afterTokenClaim(address(0), _id);
    }

    function burn(uint256 _id) external virtual {
        address burner = _msgSender();
        _burn(burner, _id);
    }

    function _burn(address _account, uint256 _id) internal virtual {
        if(balanceOf[_account][_id] == true)
            revert NotOwner(_account);
        if(amount[_id] <= 0)
            revert CanNotClaim(_account, _id);
        _beforeTokenTransfer(_account, address(0), _id, 1);
        balanceOf[_account][_id] = false;
        amount[_id]--;
        emit TokenTransfer(_account, 0, _id);
        _afterTokenTransfer(_account, address(0), _id, 1);
    }

    /**
     * @dev Hook that is called before any minting of tokens.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 id,
        uint256 _amount
    ) internal virtual {}
    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 id,
        uint256 _amount
    ) internal virtual {}

    /**
     * @dev Hook that is called before any token claim.
     */
    function _beforeTokenClaim(
        address newOwner,
        uint256 id
    ) internal virtual {}
    /**
     * @dev Hook that is called after any token claim.
     */
    function _afterTokenClaim(
        address newOwner,
        uint256 id
    ) internal virtual {}
}
