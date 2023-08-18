// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.18;

/// @custom:todo add documentation
library Int128Lib {
    /// @notice get absolute value of the input, returned as an unsigned number.
    /// @param x: signed number
    /// @return z uint128 absolute value of x
    function abs(int128 x) internal pure returns (uint128 z) {
        assembly {
            /// shr(127, x):
            /// shifts the number x to the right by 127 bits:
            /// IF the number is negative, the leftmost bit (bit 127) will be 1
            /// IF the number is positive,the leftmost bit (bit 127) will be 0

            /// sub(0, shr(127, x)):
            /// creates a mask of all 1s if x is negative
            /// creates a mask of all 0s if x is positive
            let mask := sub(0, shr(127, x))

            /// If x is negative, this effectively negates the number
            // if x is positive, it leaves the number unchanged, thereby computing the absolute value
            z := xor(mask, add(mask, x))
        }
    }
}
