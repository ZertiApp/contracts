//SPDX-License-Identifier: MIT

/**
 * @title Token contract
 * @author Matias Arazi & Lucas Grasso Ramos
 * @notice MultiSig, Semi-Fungible, SoulBound Token standard for academic certification.
 */

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "./ISBTERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SBTERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI, ISBTERC1155{

    uint256 private nonce;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://ipfs.io/ipfs/token.data
    string private _uri;

    // Mapping to token id to Token struct[creator, data(IPF-Hash)]
    mapping(uint256 => Token) internal tokens; // id to Token

    // Mapping from token ID to account balances
    mapping(address => mapping(uint256 => bool)) internal _balances; 

    // Mapping from address to mapping id bool that states if address has tokens(under id) awaiting to be claimed
    mapping(address => mapping(uint256 => bool)) internal pending;

    error NotOwner(address addr, uint256 id);

    error AddressZero();

    error AlreadyOwnedOrPending(uint256 id);

    error NotPending(uint256 id);

    /**
     * @dev Main token struct.
     * @param creator Minter/Creator of the token
     * @param data IPFS Hash of the token(In order to save gas, do not use the full URI)
     */
    struct Token {
        address creator;
        string data;
    }

    /**
     * @dev Sets base uri for tokens. Preferably "https://ipfs.io/ipfs/"
     */
    constructor(string memory uri_) {
        _uri = uri_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            interfaceId == type(ISBTERC1155).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     */
    function uri(uint256 _id)
        external
        view
        virtual
        override
        returns (string memory)
    {
        return string(abi.encodePacked(_uri, tokens[_id].data));
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        if(account == address(0)) revert AddressZero();
        if(_balances[account][id]) {
            return 1;  
        }
        else {
            return 0;
        }
        
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {

        if(accounts.length != ids.length) revert("Accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev Get tokens owned by a given address
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     *
     */
    function tokensFrom(address account)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        if(account == address(0)) revert AddressZero();

        uint256 _tokenCount = 0;
        for (uint256 i = 1; i <= nonce; ) {
            if (_balances[account][i]) {
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
            if (_balances[account][i]) {
                _ownedTokens[--_tokenCount] = i;
            }
            unchecked {
                ++i;
            }
        }
        return _ownedTokens;
    }

    /**
     * @dev Get tokens marked as pending of a given address
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     *
     */
    function pendingFrom(address account)
        external
        view
        virtual
        override
        returns (uint256[] memory)
    {
        if(account == address(0)) revert AddressZero();

        uint256 _tokenCount = 0;
        for (uint256 i = 1; i <= nonce; ) {
            if (pending[account][i]) {
                ++_tokenCount;
            }
            unchecked {
                ++i;
            }
        }
        uint256[] memory _pendingTokens = new uint256[](_tokenCount);
        for (uint256 i = 1; i <= nonce; ) {
            if (pending[account][i]) {
                _pendingTokens[--_tokenCount] = i;
            }
            unchecked {
                ++i;
            }
        }
        return _pendingTokens;
    }

    /**
     * @dev Get the URI of the tokens marked as pending of a given address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     *
     */
    function tokensURIFrom(address account)
        external
        view
        virtual
        returns (string[] memory)
    {
        if(account == address(0)) revert AddressZero();

        (uint256[] memory ownedTokens) = tokensFrom(account);
        uint256 _nTokens = ownedTokens.length;
        string[] memory tokenURIS = new string[](_nTokens);
        
        for (uint256 i = 0; i < _nTokens; ) {
            tokenURIS[i] = string(
                abi.encodePacked(_uri, tokens[ownedTokens[i]].data)
            );

            unchecked {
                ++i;
            }
        } 
        return tokenURIS;
    }

    /**
     * @dev Get the URI of the tokens owned by a given address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     *
     */
    function pendingURIFrom(address account)
        external
        view
        virtual
        returns (string[] memory)
    {
        if(account == address(0)) revert AddressZero();

        (uint256[] memory pendingTokens) = pendingFrom(account);
        uint256 _nTokens = pendingTokens.length;
        string[] memory tokenURIS = new string[](_nTokens);
        
        for (uint256 i = 0; i < _nTokens; ) {
            tokenURIS[i] = string(
                abi.encodePacked(_uri, tokens[pendingTokens[i]].data)
            );

            unchecked {
                ++i;
            }
        } 
        return tokenURIS;
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

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(nonce);
        uint256[] memory amounts = _asSingletonArray(1);
        bytes memory _bData = bytes(_data);

        _beforeTokenTransfer(operator, address(0), operator, ids, amounts, _bData);
        tokens[nonce] = Token(_account, _data);
        emit TransferSingle(operator, address(0), operator, nonce, 1);
        _afterTokenTransfer(operator, address(0), operator, ids, amounts, _bData);
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     *
     * Requirements:
     * - `from` must be the creator(minter) of `id`.
     *
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        if(from != tokens[id].creator) revert NotOwner(from,id);

        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {ISBTERC1155-safeMultiTransfer}
     *
     * Requirements:
     * - 'from' must be the creator(minter) of `id`.
     *
     */
    function safeMultiTransfer (
        address from,
        address[] memory to,
        uint256 id
    ) external virtual override {
        if(from != tokens[id].creator) revert NotOwner(from,id);
        for (uint256 i = 0; i < _totalDestinataries; ) {
            address _dest = to[i];

            if(_dest == address(0)) revert AddressZero();
            if(_balances[_dest][id] == true || pending[_dest][id] == true) revert AlreadyOwnedOrPending(id);
        }
        _safeMultiTransfer(from, to, id);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` must be the creator(minter) of the token under `id`.
     * - `to` must be non-zero.
     * - `to` must have the token `id` marked as pending.
     * - `to` must must not own a token type under `id`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     *
     */
    function _safeTransferFrom (
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        if(to == address(0)) revert AddressZero();
        if(_balances[to][id] == true || pending[to][id] == true) revert AlreadyOwnedOrPending(id);
        if(amount != 1) revert("Can only transfer one token");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        pending[to][id] = true;

        emit TransferSingle(operator, from, to, nonce, amount);
        _afterTokenTransfer(operator, from, to, ids, amounts, data);

    }

    /**
     * Transfers `_id` token from `_from` to every address at `_to[]`.
     *
     * Requirements:
     * - See {ISBTERC1155-safeMultiTransfer}.
     *
     */
    function _safeMultiTransfer(
        address from,
        address[] memory to,
        uint256 id
    ) internal virtual {
        uint256 _totalDestinataries = to.length;

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(1);

        for (uint256 i = 0; i < _totalDestinataries; ) {
            address _dest = to[i];

            _beforeTokenTransfer(operator, from, _dest, ids, amounts, "");

            pending[_dest][id] = true;

            _afterTokenTransfer(operator, from, _dest, ids, amounts, "");

            unchecked {
                ++i;
            }
        }

        emit TransferMulti(from, to, id);
    }

    /**
     * See {ISBTERC1155-_claim}
     * If action == 1-Claim pending token
     * If action == 0-Reject pending token
     */
    function claimOrReject(uint256 _id, bool _action) external virtual override {
        address _account = _msgSender();
        _claimOrReject(_account, _action, _id);
    }

    /**
     * @dev Claims or Reject pending `_id` from address `_account`.
     *
     * Requirements:
     * - `account` cannot be the zero address.
     * - `account` must have a pending token under `id` at the moment of call.
     * - `account` mUST not own a token under `id` at the moment of call.
     *
     * Emits a {TokenClaimed} event.
     *
     */
    function _claimOrReject(address account, bool action, uint256 id) internal virtual {
        if(_balances[account][id] == true) revert AlreadyOwnedOrPending(id);
        if(pending[account][id] == false) revert("Id not pending");

        address _newOwner;
        if(action){
            _newOwner = account;
        } else {
            _newOwner = address(0);
        }

        _beforeTokenClaim(_newOwner, id);

        _balances[account][id] = action;
        pending[account][id] = false;

        emit TokenClaimed(_newOwner, id);

        _afterTokenClaim(_newOwner, id);
    }

    /**
     * @dev Destroys `_id` token from `_account`
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     * - `account` must have `_id` token.
     */
    function _burn(address _account, uint256 id) internal virtual {
        if(_balances[_account][id] == false) revert("Caller is not owner");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(1);

        _beforeTokenTransfer(operator, operator, address(0), ids, amounts,"");

        _balances[_account][id] = false;

        emit TransferSingle(operator, operator, address(0), id, 1);
        _beforeTokenTransfer(operator, operator, address(0), ids, amounts,"");
    }

    
     /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - `amount` will always be and must be equal to 1.
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - `amount` will always be and must be equal to 1.
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

     /**
     * @dev Hook that is called before any token claim.
     +
     * Calling conditions (for each `newOwner` and `id` pair):
     *
     * - A token under `id` must exist.
     * - When `newOwner` is non-zero, a token typen under `id` will now be claimed and owned by`to`.
     * - When `newOwner` is zero, a token typen under `id` will now be rejected.
     * 
     * @param newOwner the address who will claim or reject the token
     * @param id the token id
     */
    function _beforeTokenClaim(address newOwner, uint256 id)
        internal
        virtual
    {}

    /**
     * @dev Hook that is called before any token claim.
     +
     * Calling conditions (for each `newOwner` and `id` pair):
     *
     * - A token under `id` must exist.
     * - When `newOwner` is non-zero, a token under `id` will now be claimed and owned by`to`.
     * - When `newOwner` is zero, a token under `id` will now be rejected.
     * 
     * @param newOwner the address who will claim or reject the token
     * @param id the token id
     */
    function _afterTokenClaim(address newOwner, uint256 id)
        internal
        virtual
    {}

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }

    /**
     * @dev Disabled function
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {revert();}

    /**
     * @dev Disabled function
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {revert();}

    /**
     * @dev Disabled function
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(address from,address to,uint256[] memory ids, uint256[] memory amounts, bytes memory data) external override {revert();}
}
