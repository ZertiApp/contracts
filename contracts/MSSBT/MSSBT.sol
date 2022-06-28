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
    mapping(uint256 => MotherCertificate) public certifications; // id to Zerti
    mapping(uint256 => uint256) public amounts; // the amounts of tokens for each Zerti
    mapping(address => mapping(uint256 => bool)) internal owners; // if owner has a specific Zerti
    mapping(address => mapping(uint256 => bool)) internal pending; // if owner has pending a specific Zerti

    struct MotherCertificate {
        address owner;
        string data;
    }

    error Unauthorized(address _sender);
    error AlreadyOwned(uint256 _id);
    error AlreadyAwaitingClaim(uint256 _id);
    error CanNotClaim(uint256 _id);
    error NotAnEntity(address _sender);
    error CeroZertisIn(uint256 _id);

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
        require(minter != address(0), "MSSBT: mint to the zero address");
        _beforeTokenTransfer(minter, minter, 1);
        _mint(minter, _data);
        _afterTokenTransfer(minter, minter, 1);
        return true;
    }

    function _mint(address account, string memory _data) internal virtual {
        certifications[++nonce] = MotherCertificate(msg.sender, _data);
        amounts[nonce] = 0;
        emit Minted(msg.sender, nonce);
    }

    function transfer(uint256 _id, address[] memory _to) external virtual returns (bool) {
        address sender = _msgSender();
        if (certifications[_id].owner != sender)
            revert Unauthorized(sender);
        _beforeTokenTransfer(sender, _to, _to.length);
        _transfer(sender, _id, _to);
        _beforeTokenTransfer(sender, _to, _to.length);
        return true;
    }

    function _transfer(address sender, uint256 _id, address[] memory _to ) internal virtual {
        for (uint256 i = 0; i < _to.length; ) {
            address dest = _to[i];
            if (owners[dest][_id] != false)
                revert AlreadyOwned(_id);
            if (pending[dest][_id] != false)
                revert AlreadyAwaitingClaim(_id);
            pending[dest][_id] = true;
            emit Transfer(sender, dest, _id);
            unchecked {
                ++i;
            }
        }
    }

    function claim(uint256 _id) external virtual returns (bool) {
        if (owners[msg.sender][_id] != false || pending[msg.sender][_id] != true)
            revert CanNotClaim(_id);
        _claim(_id);
        return true;
    }

    function _claim(uint256 _id) internal virtual {
        owners[msg.sender][_id] = true;
        pending[msg.sender][_id] = false;
        amounts[_id]++;
        emit Claimed(msg.sender, _id);
    }

    function burn(uint256 _id) external virtual returns (bool) {
        address burner = _msgSender();
        require(owners[burner][_id] == true, "MSSBT:Not Owner");
        require(amounts[_id] > 0, "MSSBT:0 Certificates");

        super._beforeTokenTransfer(burner, address(0),1);
        _burn(burner, _id);
        super._afterTokenTransfer(burner, address(0),1);
        return true;
    }

    function _burn(address account, uint256 _id) internal virtual {
        owners[account][_id] = false;
        amounts[_id]--;
        emit Burned(account, _id);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
