// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {ERC165Identifier} from "../src/utils/ERC165Identifier.sol";
import "forge-std/console.sol";

contract TransformerTest is Test {
    ERC165Identifier public erc165Identifier;

    function setUp() public {
        erc165Identifier = new ERC165Identifier();
    }

    function testTransform() public {
        bytes32 hash1 = erc165Identifier.transform("transferAndCall(address,uint256)");
        bytes32 hash2 = erc165Identifier.transform("transferAndCall(address,uint256,bytes)");
        bytes32 hash3 = erc165Identifier.transform("transferFromAndCall(address,address,uint256)");
        bytes32 hash4 = erc165Identifier.transform("transferFromAndCall(address,address,uint256,bytes)");
        bytes32 hash5 = erc165Identifier.transform("approveAndCall(address,uint256)");
        bytes32 hash6 = erc165Identifier.transform("approveAndCall(address,uint256,bytes)");
        emit log_named_bytes32("hash1", hash1);
        emit log_named_bytes32("hash2", hash2);
        emit log_named_bytes32("hash3", hash3);
        emit log_named_bytes32("hash4", hash4);
        emit log_named_bytes32("hash5", hash5);
        emit log_named_bytes32("hash6", hash6);

        bytes4 hashed1 = erc165Identifier.returnsBytes4(hash1);
        bytes4 hashed2 = erc165Identifier.returnsBytes4(hash2);
        bytes4 hashed3 = erc165Identifier.returnsBytes4(hash3);
        bytes4 hashed4 = erc165Identifier.returnsBytes4(hash4);
        bytes4 hashed5 = erc165Identifier.returnsBytes4(hash5);
        bytes4 hashed6 = erc165Identifier.returnsBytes4(hash6);

        console.logBytes4(hashed1);
        console.logBytes4(hashed2);
        console.logBytes4(hashed3);
        console.logBytes4(hashed4);
        console.logBytes4(hashed5);
        console.logBytes4(hashed6);
    }
}
