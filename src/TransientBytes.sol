// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

library TransientBytes {
    function set(bytes calldata input, bytes32 slot) external {
        _storeBytes(input, slot);
    }
    function set(bytes calldata input) external returns (bytes32 slot) {
        slot = keccak256(abi.encodePacked(input));
        _storeBytes(input, slot);
    }
    function _storeBytes(bytes calldata input, bytes32 slot) internal {
        assembly {
            let length := calldataload(sub(input.offset, 32)) 
            tstore(slot, length) // Store the length in the slot

            // Calculate the starting storage slot for the data
            let dataSlot := add(slot, 1)

            // Calculate the number of full 32-byte chunks and remaining bytes
            let fullWords := div(length, 32)
            let remainder := mod(length, 32)

            // Pointer to the first byte of input data
            let dataPtr := input.offset

            // Store full 32-byte chunks
            for { let i := 0 } lt(i, fullWords) { i := add(i, 1) } {
                tstore(add(dataSlot, i), calldataload(add(dataPtr, mul(i, 32))))
            }

            // Handle any remaining bytes
            if remainder {
                let lastWord := calldataload(add(dataPtr, mul(fullWords, 32)))
                tstore(add(dataSlot, fullWords), and(lastWord, not(0)))
            }
        }
    }
    function get(bytes32 slot) external view returns (bytes memory result) {
        return _retrieveBytes(slot);
    }

    function delet(bytes32 slot) external {
        _deleteBytes(slot);
    }

    function _retrieveBytes(bytes32 slot) internal view returns (bytes memory result) {
        assembly {
            // Load the length of the bytes array from transient storage
            let length := tload(slot)

            result := mload(0x40)
            mstore(result, length)

            // Calculate the starting storage slot for the data
            let dataSlot := add(slot, 1)

            // Calculate the number of full 32-byte chunks and remaining bytes
            let fullWords := div(length, 32)
            let remainder := mod(length, 32)

            // Pointer to write the data in memory (after the length word)
            let writePtr := add(result, 0x20)

            // Load full 32-byte chunks from transient storage into memory
            for { let i := 0 } lt(i, fullWords) { i := add(i, 1) } {
                mstore(add(writePtr, mul(i, 32)), tload(add(dataSlot, i)))
            }

            // Handle any remaining bytes
            if remainder {
                let lastWord := tload(add(dataSlot, fullWords))
                mstore(add(writePtr, mul(fullWords, 32)), and(lastWord, not(0)))
            }
            mstore(0x40, add(writePtr, mul(add(fullWords, gt(remainder, 0)), 32)))
        }
    }

    function _deleteBytes(bytes32 slot) internal {
        assembly {
            tstore(slot, 0)
        }
    }
}

