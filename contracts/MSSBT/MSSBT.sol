//SPDX-License-Identifier: MIT

/**
 * @title Badge contract
 * @author Zerti Team - Matias Arazi & Lucas Grasso Ramos
 * @notice MultiSig, Semi-Fungible, SoulBound Token standard for academic certification.
 */

pragma solidity ^0.8.4;

import "./utils.sol";

contract MSSBT is Context {

    uint256 private nonce;
    mapping(uint256 => MotherCertificate) public certifications; 
    mapping(uint256 => uint256) public amounts; 
    mapping(address => mapping(uint256 => bool)) internal owners; 
    mapping(address => mapping(uint256 => bool)) internal pending; 

    struct MotherCertificate {
        address owner;
        string data;
    }

    event Minted(
        address _entity,
        uint256 _id
    );

    event Transfer(
        address _from,
        address _to,
        uint256 _id
    );

    event Claimed(
        address _newOwner,
        uint256 _id
    );

    event Burned(
        address _owner,
        uint256 _id
    );
    
    //Function
    function mint(string calldata _data) external virtual returns (bool){
        address minter = _msgSender();
        _beforeTokenTransfer(minter, minter, 1);
        _mint(minter, _data);
        _afterTokenTransfer(minter, minter, 1);
        return true;
    }

    function _mint(address account, string memory _data) internal virtual {
        require(account != address(0), "MSSBT: minter is zero address");
        certifications[++nonce] = MotherCertificate(account, _data);
        amounts[nonce] = 0;
        emit Minted(account, nonce);
    }

     function transfer(uint256 _id, address _to) external virtual returns (bool) {
        address from = _msgSender();
        _beforeTokenTransfer(from, _to , 1);
        _transfer(from, _id, _to);
        _afterTokenTransfer(from, _to, 1); 
        return true;
    }

    function _transfer(address _from, uint256 _id, address _to ) internal virtual {
        require(certifications[_id].owner == _from, "MSSBT: Unauthorized");
        pending[_to][_id] = true;
        emit Transfer(_from, _to, _id);
    }

    function multiTransfer(uint256 _id, address[] memory _to) external virtual returns (bool) {
        address from = _msgSender();
        _multiTransfer(from, _id, _to);
        return true;
    }

    function _multiTransfer(address _from, uint256 _id, address[] memory _to ) internal virtual {
        require(certifications[_id].owner == _from, "MSSBT: Unauthorized");
        for (uint256 i = 0; i < _to.length; ) {
            address dest = _to[i];
            require(owners[dest][_id] == false,"MSSBT: Already Owned");
            require(pending[dest][_id] == false,"MSSBT: Already to be claimed");
            _beforeTokenTransfer(_from, dest , _to.length);
            pending[dest][_id] = true;
            emit Transfer(_from, dest, _id);
            _afterTokenTransfer(_from, dest, _to.length);
            unchecked {++i;}
        }
    }

    function claim(uint256 _id) external virtual returns (bool) {
        address claimer = _msgSender();
        _beforeTokenClaim(claimer, _id);
        _claim(claimer, _id);
        _afterTokenClaim(claimer, _id);
        return true;
    }

    function _claim(address account, uint256 _id) internal virtual {
        require (owners[account][_id] == false, "MSSBT: Already Owned");
        require (pending[account][_id] == true, "MSSBT: Not pending");
        owners[account][_id] = true;
        pending[account][_id] = false;
        amounts[_id]++;
        emit Claimed(account, _id);
    }

    function burn(uint256 _id) external virtual returns (bool) {
        address burner = _msgSender();
        _beforeTokenTransfer(burner, address(0),1);
        _burn(burner, _id);
        _afterTokenTransfer(burner, address(0),1);
        return true;
    }

    function _burn(address account, uint256 _id) internal virtual {
        require(owners[account][_id] == true, "MSSBT: Unauthorized");
        require(amounts[_id] > 0, "MSSBT: Cero Certificates");
        owners[account][_id] = false;
        amounts[_id]--;
        emit Burned(account, _id);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    /**
     * @dev Hook that is called before any claim.
     */
    function _beforeTokenClaim(
        address newOwner,
        uint256 id
    ) internal virtual {}
    /**
     * @dev Hook that is called after any claim.
     */
    function _afterTokenClaim(
        address newOwner,
        uint256 id
    ) internal virtual {}
}
