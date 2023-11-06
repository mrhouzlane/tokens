// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {TokenSale} from "../src/TokenSale.sol";
import "forge-std/console.sol";

contract TokenSaleTest is Test {
    TokenSale public tokenSale;

    function setUp() public {
        address owner = vm.addr(0x20);
        tokenSale = new TokenSale(owner, "RS", "RS");
    }

    function testCalculatePrice() public {
        address owner = vm.addr(0x20);
        vm.startPrank(owner);
        tokenSale.mint(owner, 20);
        uint256 price = tokenSale.calculatePrice(); // 1+ (20*10 * 0.1)
        assertEq(price, 21 ether);
        vm.stopPrank();
    }

    function testBuyToken() public {}

    function testBuyBack() public {
        address Bob = vm.addr(0x21);

        vm.startPrank(Bob);
        vm.deal(Bob, 20 ether);
        tokenSale.buyToken{value: 2 ether}(2); // User buys 2 tokens
        tokenSale.buyBack(1); // User sells 1 token
        vm.stopPrank();
    }

    function testFail_WithdrawNotOwner() public {
        address receiver = vm.addr(0x21);
        address Bob = vm.addr(0x22);

        vm.startPrank(Bob);
        vm.expectRevert(bytes("CALLER_NOT_OWNER"));
        (bool revertsAsExpected) = tokenSale.withdraw(receiver);
        vm.stopPrank();
        assertTrue(revertsAsExpected, "expectRevert: call did not revert");
    }

    function testWithdraw() public {}
}
