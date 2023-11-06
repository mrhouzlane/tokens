// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract ERC165Identifier {
    function transform(string memory _string) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_string));
    }

    function returnsBytes4(bytes32 _bytes32) external pure returns (bytes4) {
        return bytes4(_bytes32);
    }
}
