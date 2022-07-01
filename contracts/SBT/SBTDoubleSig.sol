//SPDX-License-Identifier: MIT

/**
 * @title Token contract
 * @author Matias Arazi & Lucas Grasso Ramos
 * @notice MultiSig, Semi-Fungible, SoulBound Token standard for academic certification.
 */

pragma solidity ^0.8.4;

import "./ISBTDoubleSig.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract SBTDoubleSig is IERC1415, Context {

    uint256 private nonce;
    mapping(uint256 => Token) public tokens; // id to Token
    mapping(uint256 => uint256) public amount; // the amounts of tokens for each Token
    mapping(address => mapping(uint256 => bool)) internal owners; // if owner has a specific Token
    mapping(address => mapping(uint256 => bool)) internal pending; // if owner has pending a specific Token

    struct Token {
        address owner;
        string data;
    }

    error NotOwner(address _sender);
    error AlreadyOwned(uint256 _id);
    error AlreadyPending(uint256 _id);
    error CanNotClaim(uint256 _id);
    error CeroTokensIn(uint256 _id);

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
    *@param _account the one who will mint the token
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

    function transfer(uint256 _id, address calldata _to) external virtual override {
        address from = _msgSender();
        _transfer(from, _id, _to);
    }

    function _transfer(address _from, uint256 _id, address memory _to ) internal virtual {
        if (tokens[_id].owner != _from)
            revert NotOwner(_from);
        if (owners[_to][_id] != false)
            revert AlreadyOwned(_id);
        if (pending[_to][_id] != false)
            revert AlreadyPending(_id);
        _beforeTokenTransfer(_from, _to, nonce, 1);
        pending[_to][_id] = true;
        emit TokenTransfer(_from, dest, _id);
    }
    
    function transferBatch(uint256 _id, address[] calldata _to) external virtual override {
        address from = _msgSender();
        _transferBath(from, _id, _to);
    }

    function _transferBatch(address _from, uint256 _id, address[] memory _to ) internal virtual {
        if (tokens[_id].owner != _from)
            revert NotOwner(_from);
        for (uint256 i = 0; i < _to.length; ) {
            address _dest = _to[i];
            if (owners[_dest][_id] != false)
                revert AlreadyOwned(_id);
            if (pending[_dest][_id] != false)
                revert AlreadyPending(_id);
            _transfer(_from, _id, _dest);
            unchecked {
                ++i;
            }
        }
    }

    function claim(uint256 _id) external virtual {
        address claimer = _msgSender();
        _claim(msg.sender, _id);
    }

    function _claim(address account, uint256 _id) internal virtual {
        if (owners[account][_id] != false || pending[account][_id] != true)
            revert CanNotClaim(_id);
        _beforeTokenClaim(account, _id);
        owners[account][_id] = true;
        pending[account][_id] = false;
        amount[_id]++;
        emit TokenClaimed(account, true, _id);
        _afterTokenClaim(account, _id);
    }

    function reject(uint256 _id) external virtual {
        address _account = _msgSender();
        _reject(_account, _id);
    }

    function _reject(address account, uint256 _id) internal virtual {
        if (owners[account][_id] != false || pending[account][_id] != true)
            revert CanNotClaim(_id);
        _beforeTokenClaim(address(0), _id);
        owners[account][_id] = false;
        pending[account][_id] = false;
        emit TokenClaimed(address(0), _id);
        _afterTokenClaim(address(0), _id);
    }

    function burn(uint256 _id) external virtual {
        address burner = _msgSender();
        _burn(burner, _id);
    }

    function _burn(address account, uint256 _id) internal virtual {
        if(owners[account][_id] == true)
            revert NotOwner(account);
        if(amount[_id] <= 0)
            revert CeroTokensIn(_id);
        _beforeTokenTransfer(account, address(0), _id, 1);
        owners[account][_id] = false;
        amount[_id]--;
        emit TokenTransfer(account, 0, _id);
        _afterTokenTransfer(account, address(0), _id, 1);
    }

    /**
     * @dev Hook that is called before any minting of tokens.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 id,
        uint256 amount
    ) internal virtual {}
    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 id,
        uint256 amount
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
