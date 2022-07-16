//SPDX-License-Identifier: MIT

/**
 * @title Token contract
 * @author Matias Arazi & Lucas Grasso Ramos
 * @notice MultiSig, Semi-Fungible, SoulBound Token standard for academic certification.
 */

pragma solidity ^0.8.4;

import "./ISBTDS.sol";
import "../@openzeppelin/Context.sol";
import "../@openzeppelin/ERC165.sol";

/* import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol"; */

contract SBTDS is Context, ERC165, ISBTDS {
    uint256 private nonce;
    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;
    mapping(uint256 => Token) internal tokens; // id to Token
    mapping(uint256 => uint256) internal amount; // the amounts of tokens for each Token
    mapping(address => mapping(uint256 => bool)) internal balanceOf; // if owner has a specific Token
    mapping(address => mapping(uint256 => bool)) internal pending; // if owner has pending a specific Token

    /**
     * @dev Main token struct.
     */
    struct Token {
        address owner;
        string data;
    }

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }


    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return
            interfaceId == type(ISBTDS).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev Custom Errors
     */
    error NotOwner(address _sender);
    error AlreadyOwned(address _account, uint256 _id);
    error AlreadyPending(address _account, uint256 _id);
    error CanNotClaim(address _account, uint256 _id);
    error CeroAddressError(address _account1, address _account2);

    /* 
     * @dev See {IERC165-supportsInterface}.
     *
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(ISBTDoubleSig).interfaceId ||
            super.supportsInterface(interfaceId);
    } */

    /**
     * @dev See {ISBTDoubleSig-uri}.
     */
    function uri() external view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {ISBTDoubleSig-ownerOf}.
     */
    function ownerOf(uint256 _id)
        external
        view
        virtual
        override
        returns (address)
    {
        return (tokens[_id].owner);
    }

    /**
     * @dev See {ISBTDoubleSig-uriOf}.
     */
    function uriOf(uint256 _id)
        external
        view
        virtual
        override
        returns (string memory)
    {
        return (tokens[_id].data);
    }

    /**
     * @dev See {ISBTDoubleSig-amountOf}.
     */
    function amountOf(uint256 _id)
        external
        view
        virtual
        override
        returns (uint256)
    {
        return (amount[_id]);
    }

    /**
     * @dev See {ISBTDoubleSig-tokensFrom}.
     */
    function tokensFrom(address _from)
        external
        view
        virtual
        override
        returns (uint256[] memory)
    {
        uint256 _tokenCount = 0;
        for (uint256 i = 1; i <= nonce; ) {
            if (balanceOf[_from][i]) {
                unchecked {
                    ++_tokenCount;
                }
            }
            unchecked {
                ++i;
            }
        }
        uint256[] memory _ownedTokens = new uint256[](_tokenCount);
        for (uint256 i = 1; i <= nonce; ) {
            if (balanceOf[_from][i]) {
                _ownedTokens[--_tokenCount] = i;
            }
            unchecked {
                ++i;
            }
        }
        return _ownedTokens;
    }

    /**
     * @dev sets newURI.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev See {ISBTDoubleSig-pendingFrom}.
     */
    function pendingFrom(address _from)
        external
        view
        virtual
        override
        returns (uint256[] memory)
    {
        uint256 _tokenCount = 0;
        for (uint256 i = 1; i <= nonce; ) {
            if (pending[_from][i]) {
                ++_tokenCount;
            }
            unchecked {
                ++i;
            }
        }
        uint256[] memory _pendingTokens = new uint256[](_tokenCount);
        for (uint256 i = 1; i <= nonce; ) {
            if (pending[_from][i]) {
                _pendingTokens[--_tokenCount] = i;
            }
            unchecked {
                ++i;
            }
        }
        return _pendingTokens;
    }

    /**
     *@dev mints(creates) a token
     *@param _account address who will mint the token
     *@param _data the uri of the token
     */
    function _mint(address _account, string memory _data) internal virtual {
        unchecked {
            ++nonce;
        }
        _beforeTokenTransfer(address(0), _account, nonce, 0);
        tokens[nonce] = Token(_account, _data);
        amount[nonce] = 0;
        emit TokenTransfer(address(0), msg.sender, nonce);
        _afterTokenTransfer(address(0), _account, nonce, 0);
    }

    /**
     * @dev see {ISBTDoubleSig-transfer}
     */
    function transfer(uint256 _id, address _to)
        external
        virtual
        override
        returns (bool)
    {
        address from = _msgSender();
        _transfer(from, _id, _to);
        return true;
    }

    /**
     * @dev see {ISBTDoubleSig-transfer}
     */
    function _transfer(
        address _from,
        uint256 _id,
        address _to
    ) internal virtual {
        if (_from == address(0) || _to == address(0))
            revert CeroAddressError(_from, _to);
        if (tokens[_id].owner != _from) revert NotOwner(_from);
        if (balanceOf[_to][_id] != false) revert AlreadyOwned(_to, _id);
        if (pending[_to][_id] != false) revert AlreadyPending(_to, _id);
        _beforeTokenTransfer(_from, _to, nonce, 1);
        pending[_to][_id] = true;
        _afterTokenTransfer(_from, _to, nonce, 1);
        emit TokenTransfer(_from, _to, _id);
    }

    /**
     * @dev see {ISBTDoubleSig-transferBatch}
     */
    function transferBatch(uint256 _id, address[] calldata _to)
        external
        virtual
        override
        returns (bool)
    {
        address from = _msgSender();
        _transferBatch(from, _id, _to);
        return true;
    }

    /**
     * @dev see {ISBTDoubleSig-transferBatch}
     */
    function _transferBatch(
        address _from,
        uint256 _id,
        address[] memory _to
    ) internal virtual {
        if (tokens[_id].owner != _from) revert NotOwner(_from);
        for (uint256 i = 0; i < _to.length; ) {
            address _dest = _to[i];
            if (balanceOf[_dest][_id] != false) revert AlreadyOwned(_dest, _id);
            if (pending[_dest][_id] != false) revert AlreadyPending(_dest, _id);
            _transfer(_from, _id, _dest);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * See {SBTDoubleSig-_claim}
     */
    function claim(uint256 _id) external virtual {
        address claimer = _msgSender();
        _claim(claimer, _id);
    }

    /**
     * @dev Claims pending `_id` from address `_account`.
     *
     * Requirements:
     * - `_account` cannot be the zero address.
     * - `_account` MUST have a pending token under `id`.
     * - `_account` MUST NOT own a token under `id`.
     *
     * Emits a {TokenClaimed} event.
     *
     */
    function _claim(address _account, uint256 _id) internal virtual {
        if (_account == address(0)) revert CeroAddressError(_account, _account);
        if (balanceOf[_account][_id] != false || pending[_account][_id] != true)
            revert CanNotClaim(_account, _id);

        _beforeTokenClaim(_account, _id);
        balanceOf[_account][_id] = true;
        pending[_account][_id] = false;
        unchecked {
            amount[_id]++;
        }
        emit TokenClaimed(_account, _id);
        _afterTokenClaim(_account, _id);
    }

    /**
     * See {SBTDoubleSig-_reject}
     */
    function reject(uint256 _id) external virtual {
        address _account = _msgSender();
        _reject(_account, _id);
    }

    /**
     * @dev Rejects pending `_id` from address `_account`.
     *
     * Requirements:
     *  - See {SBTDoubleSig-_claim}
     *
     * Emits a {TokenClaimed} event.
     *
     */
    function _reject(address _account, uint256 _id) internal virtual {
        if (_account == address(0)) revert CeroAddressError(_account, _account);
        if (balanceOf[_account][_id] != false || pending[_account][_id] != true)
            revert CanNotClaim(_account, _id);

        _beforeTokenClaim(address(0), _id);
        balanceOf[_account][_id] = false;
        pending[_account][_id] = false;
        emit TokenClaimed(address(0), _id);
        _afterTokenClaim(address(0), _id);
    }

    /**
     * See {SBTDoubleSig-_burn}
     */
    function burn(uint256 _id) external virtual {
        address burner = _msgSender();
        _burn(burner, _id);
    }

    /**
     * @dev Destroys `_id` token from `_account`
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     * - `account` cannot be the zero address.
     * - `account` must have `_id` token.
     * - There must be at least one token under `_id`
     */
    function _burn(address _account, uint256 _id) internal virtual {
        if (balanceOf[_account][_id] == true) revert NotOwner(_account);
        if (amount[_id] <= 0) revert CanNotClaim(_account, _id);
        _beforeTokenTransfer(_account, address(0), _id, 1);
        balanceOf[_account][_id] = false;
        unchecked {
            amount[_id]--;
        }
        emit TokenTransfer(_account, address(0), _id);
        _afterTokenTransfer(_account, address(0), _id, 1);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes minting and burning.
     * @param _from the address who will make the token transfer
     * @param _to the address who will receive the token transfer
     * @param _id the token id
     * @param _amount the amount of tokens that will be transfered
     */
    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     * @param _from the address who has make the token transfer
     * @param _to the address who has received the token transfer
     * @param _id the token id
     * @param _amount the amount of tokens that was transfered
     */
    function _afterTokenTransfer(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount
    ) internal virtual {}

    /**
     * @dev Hook that is called before any token claim.
     * @param _newOwner the address who will claim or reject the token
     * @param _id the token id
     */
    function _beforeTokenClaim(address _newOwner, uint256 _id)
        internal
        virtual
    {}

    /**
     * @dev Hook that is called after any token claim.
     * @param _newOwner the address who has claimed or rejected the token
     * @param _id the token id
     */
    function _afterTokenClaim(address _newOwner, uint256 _id)
        internal
        virtual
    {}
}
