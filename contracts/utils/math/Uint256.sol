// SPDX-License-Identifier: MIT
/**
 * @title SafeCast
 * @author Lucas Grasso - Zerti
 */
pragma solidity ^0.8.0;

library Uint256 {
	/**
	 * @dev Converts a uint256 to a uint256[] of length 1.
	 * @param _value uint256 element to be converted to array
	 */
	function _asSingletonArray(uint256 _value) internal pure returns (uint256[] memory) {
		uint256[] memory array = new uint256[](1);
		array[0] = _value;

		return array;
	}
}
