//SPDX-License-Identifier: MIT

/**
 * @title Badge contract
 * @author Zerti Team - Matias Arazi & Lucas Grasso Ramos
 * @notice Badge contract use for storing your badges as SBTs
 */
pragma solidity ^0.8.4;

import "./SBT/ISBTDS.sol";
import "./SBT/SBTDS.sol";
import "./IVF.sol";

contract BadgeZerti is SBTDS {

    address public immutable zertiWallet;
    address public immutable voteFactory;

    mapping (address => bool) internal allowances;

    error AllowanceError(address _addr);
    error Unauthorized(address _addr);
    error NotAnEntity(address _sender);

    constructor(string memory _uri, address _zertiWallet, address _voteFactory) SBTDS(_uri) {
        zertiWallet = _zertiWallet;
        voteFactory = _voteFactory;
    }

    /**
     * @dev see {SBTDoubleSig-_mint}
     */
    function mint(string memory _data) external {
        _mint(msg.sender, _data);
    }

    /**
     * @dev see {SBTDoubleSig-_mint}
     */
    function entityMint(string memory _data) external {
        if(!IVF(voteFactory).isEntity(msg.sender))
                revert NotAnEntity(msg.sender);
        _mint(msg.sender, _data);
    }

    function transfer(
        uint256 _id,
        address _to,
        string memory _newData
    ) external returns (bool) {
        address from = _msgSender();
        _transfer(from, _id, _to);
        tokens[_id].data = _newData;
        return true;
    }

    function claim(uint256 _id, address claimer) external {
        if (msg.sender == zertiWallet) {
            if (!allowances[claimer]) revert AllowanceError(claimer);
            _claim(claimer, _id);
        } else {
            if (msg.sender != claimer) revert AllowanceError(claimer);
            _claim(claimer, _id);
        }
    }

    function reject(uint256 _id, address rejecter) external {
        if (msg.sender == zertiWallet) {
            if (!allowances[rejecter]) revert AllowanceError(rejecter);
            _reject(rejecter, _id);
        } else {
            if (msg.sender != rejecter) revert AllowanceError(rejecter);
            _reject(rejecter, _id);
        }
    }

    function setAllowance() external {
        allowances[msg.sender] = !allowances[msg.sender];
    } 
}
