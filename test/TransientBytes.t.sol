// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {TransientBytes} from "../src/TransientBytes.sol";
import {console2} from "forge-std/console2.sol";
contract TransientBytesTest is Test {

    function setUp() public {
    }

    function test_storeBytes() public {
        bytes memory data = "Hello, World!";
        bytes32 slot = 0;
        TransientBytes.set(data, bytes32(slot));
        bytes memory retrievedData = TransientBytes.get(slot);
        assertEq(keccak256(data), keccak256(retrievedData), "Retrieved data does not match stored data");
    }

    function test_deleteBytes() public {
        bytes memory data = "Hello, World!";
        bytes32 slot = 0;
        TransientBytes.set(data, bytes32(slot));
        TransientBytes.delet(slot);
        bytes memory retrievedData = TransientBytes.get(slot);
        console.logBytes(retrievedData);
        assertEq(keccak256(new bytes(0)), keccak256(retrievedData), "Retrieved data does not match stored data");
    }

    function testFuzz_deleteBytes(bytes memory data, bytes32 slot) public {
        TransientBytes.set(data, bytes32(slot));
        TransientBytes.delet(slot);
        bytes memory retrievedData = TransientBytes.get(slot);
        console.logBytes(retrievedData);
        assertEq(keccak256(new bytes(0)), keccak256(retrievedData), "Retrieved data does not match stored data");
    }

    function test_storeBytes_noAddress() public {
        bytes memory data = "Hello, World!";
        bytes32 ptr = TransientBytes.set(data);
        bytes memory retrievedData = TransientBytes.get(ptr);
        assertEq(keccak256(data), keccak256(retrievedData), "Retrieved data does not match stored data");
    }
    
    function testFuzz_storeBytes(bytes memory data, bytes32 slot) public {
        TransientBytes.set(data, bytes32(slot));
        bytes memory retrievedData = TransientBytes.get(slot);
        assertEq(keccak256(data), keccak256(retrievedData), "Retrieved data does not match stored data");
    }

    function testFuzz_storeBytes_noAddress(bytes memory data) public {
        bytes32 ptr = TransientBytes.set(data);
        bytes memory retrievedData = TransientBytes.get(ptr);
        assertEq(keccak256(data), keccak256(retrievedData), "Retrieved data does not match stored data");
    }
}
