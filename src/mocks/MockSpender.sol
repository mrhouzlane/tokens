// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";

contract MockERC1363Spender is IERC1363Spender {
    function onApprovalReceived(address owner, uint256 value, bytes calldata data) external returns (bytes4) {
        return this.onApprovalReceived.selector;
    }
}
