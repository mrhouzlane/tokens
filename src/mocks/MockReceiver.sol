// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";

contract MockERC1363Receiver is IERC1363Receiver {
    function onTransferReceived(address operator, address from, uint256 value, bytes calldata data)
        external
        pure
        override
        returns (bytes4)
    {
        return this.onTransferReceived.selector;
    }
}
