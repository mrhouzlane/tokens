// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {TokenSale} from "../src/TokenSale.sol";
import "forge-std/console.sol";

contract TokenSaleTest is Test {
    TokenSale public tokenSale;

    function setUp() public {
        address owner = vm.addr(0x20);
        tokenSale = new TokenSale(owner, "RaReSkills", "RSK");
    }

    function testCalculatePrice() public {
        address owner = vm.addr(0x20);
        uint256 startPrice = 1 ether; 
        uint256 priceIncrement = 0.1 ether;
        uint256 totalSupply0 = 200;     //   200 
        uint256 totalSupply1 = 500;  //  700 
        uint256 totalSupply2 = 100;  // 800 
        vm.startPrank(owner);
        tokenSale.mint(owner, totalSupply0);
        uint256 price0 = tokenSale.calculatePrice();
        tokenSale.mint(owner, totalSupply1);
        uint256 price1 = tokenSale.calculatePrice();
        tokenSale.mint(owner, totalSupply2);
        uint256 price2 = tokenSale.calculatePrice();

        console.log("price0: %s", price0);
        console.log("price1: %s", price1);
        console.log("price2: %s", price2);

        // Assertions 
        assertGt(price1, price0); 
        assertLt(price1, price2); 
    
    }

    function testBuyToken() public {}

    function testBuyBack() public {
        address Bob = vm.addr(0x21);

        vm.startPrank(Bob);
        vm.deal(Bob, 20 ether);
        tokenSale.buyToken{value: 3 ether}(2); // User buys 2 tokens
        tokenSale.buyBack(1, 500000); // User sells 1 token
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
