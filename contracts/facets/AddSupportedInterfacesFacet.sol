//SPDX-License-Identifier: CC0-1.0

/**
 * @notice Adding support for ERC5516 interfaces
 */

pragma solidity >=0.8.9;

import "../interfaces/ERC1155/IERC1155.sol";
import "../interfaces/ERC1155/IERC1155MetadataURI.sol";
import "../interfaces/ERC1155/IERC1155Receiver.sol";
import "../interfaces/IERC5516.sol";
import { LibDiamond } from "../libraries/LibDiamond.sol";

contract AddSupportedInterfacesFacet {

    bool private init = false;

    function addSupportedInterfaces() external {
        require(!init, "AddSupportedInterfacesFacet: Already initialized");
        LibDiamond.enforceIsContractOwner();
        _addSupportedInterfaces();
    }

    function _addSupportedInterfaces() internal {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC5516).interfaceId] = true;
        ds.supportedInterfaces[type(IERC1155).interfaceId] = true;
        ds.supportedInterfaces[type(IERC1155MetadataURI).interfaceId] = true;
        ds.supportedInterfaces[type(IERC1155Receiver).interfaceId] = true;
        init = true;
    }

}
