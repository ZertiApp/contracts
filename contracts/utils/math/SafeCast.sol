// SPDX-License-Identifier: MIT
/**
 * @title SafeCast
 * @author OppenZeppelin
 */
pragma solidity ^0.8.0;

library SafeCast {
	/**
	 * @dev Returns the downcasted uint64 from uint256, reverting on
	 * overflow (when the input is greater than largest uint64).
	 *
	 * Requirements:
	 *
	 * - input must fit into 64 bits
	 *
	 */
	function toUint64(uint256 value) internal pure returns (uint64) {
		require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
		return uint64(value);
	}
}
