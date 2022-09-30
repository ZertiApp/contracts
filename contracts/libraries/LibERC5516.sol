
//SPDX-License-Identifier: CC0-1.0

/**
 * @notice Implementation of the eip-5516 interface.
 * Note: this implementation only allows for each user to own only 1 token type for each `id`.
 * @author Matias Arazi <matiasarazi@gmail.com> , Lucas Martín Grasso Ramos <lucasgrassoramos@gmail.com>
 * See https://eips.ethereum.org/EIPS/eip-5516
 *
 */

pragma solidity >=0.8.9;

library LibERC5516{

    bytes32 constant internal ERC5516_STORAGE_POSITION = keccak256("ERC5516.facet.storage");

    struct ERC5516Storage {
        // Used for making each token unique, Maintains ID registry and quantity of tokens minted.
        uint256 nonce;
        // Mapping from token ID to account balances
        mapping(address => mapping(uint256 => bool)) balances;

        // Mapping from address to mapping id bool that states if address has tokens(under id) awaiting to be claimed
        mapping(address => mapping(uint256 => bool)) pendings;

        // Mapping from account to operator approvals
        mapping(address => mapping(address => bool)) operatorApprovals;

        // Mapping from ID to minter address.
        mapping(uint256 => address) tokenMinters;

        // Mapping from ID to URI.
        mapping(uint256 => string) tokenUris;

        // Used as the URI for all token types by relying on ID substitution, e.g. https://ipfs.io/ipfs/token.data
        string uri;

        string name; string symbol;

        string contractUri;
    }

    function diamondStorage() internal pure returns (ERC5516Storage storage ds) {
      bytes32 position = ERC5516_STORAGE_POSITION;
      assembly {
          ds.slot := position
        }
    }
    
    //NONCE FUNCTIONS
    function getNonce() internal view returns (uint256) {
        ERC5516Storage storage ds = diamondStorage();
        return ds.nonce;
    }

    function addToNonce() internal {
        ERC5516Storage storage ds = diamondStorage();
        ds.nonce++;
    }
    //NONCE FUNCTIONS

    //BALANCE FUNCTIONS
    function setBalance(address _account, uint256 _id, bool balance) internal {
        ERC5516Storage storage ds = diamondStorage();
        ds.balances[_account][_id] = balance;
    }

    function getBalance(address _account, uint256 _id) internal view returns (bool) {
        ERC5516Storage storage ds = diamondStorage();
        return ds.balances[_account][_id];
    }
    //BALANCE FUNCTIONS

    //PENDING FUNCTIONS
    function setPending(address _account, uint256 _id, bool pending) internal {
        ERC5516Storage storage ds = diamondStorage();
        ds.pendings[_account][_id] = pending;
    }

    function getPending(address _account, uint256 _id) internal view returns (bool) {
        ERC5516Storage storage ds = diamondStorage();
        return ds.pendings[_account][_id];
    }
    //PENDING FUNCTIONS

    //OPERATOR FUNCTIONS
    function setApproval(address _owner, address _operator, bool _approved) internal {
        ERC5516Storage storage ds = diamondStorage();
        ds.operatorApprovals[_owner][_operator] = _approved;
    }

    function getApproved(address _owner, address _operator) internal view returns (bool) {
        ERC5516Storage storage ds = diamondStorage();
        return ds.operatorApprovals[_owner][_operator];
    }
    //OPERATOR FUNCTIONS

    //TOKEN FUNCTIONS
    function setTokenMinter(uint256 _id, address _minter) internal {
        ERC5516Storage storage ds = diamondStorage();
        ds.tokenMinters[_id] = _minter;
    }

    function getTokenMinter(uint256 _id) internal view returns (address) {
        ERC5516Storage storage ds = diamondStorage();
        return ds.tokenMinters[_id];
    }

    function setTokenURI(uint256 _id, string memory _uri) internal {
        ERC5516Storage storage ds = diamondStorage();
        ds.tokenUris[_id] = _uri;
    }

    function getTokenURI(uint256 _id) internal view returns (string memory) {
        ERC5516Storage storage ds = diamondStorage();
        return ds.tokenUris[_id];
    }
    //TOKEN FUNCTIONS

}