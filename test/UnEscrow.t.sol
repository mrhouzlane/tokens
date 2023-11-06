// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {UnEscrow} from "../src/UnEscrow.sol";
import {MockERC20} from "../src/mocks/MockERC20.sol";
import "forge-std/console.sol";

contract UnEscrowTest is Test {
    UnEscrow public unEscrow;

    function setUp() public {
        address buyer = vm.addr(0x50);
        address seller = vm.addr(0x70);
        unEscrow = new UnEscrow(buyer, seller);
    }

    function testDepositTokens() public {
        MockERC20 token1 = new MockERC20();
        MockERC20 token2 = new MockERC20();

        address buyer = vm.addr(0x50);
        address seller = vm.addr(0x70);

        token1.mint(buyer, 200);
        token1.mint(seller, 200);

        token2.mint(buyer, 200);

        // approve unEscrow to spend tokens on behalf of buyer
        token1.approve(address(unEscrow), 200);
        token2.approve(address(unEscrow), 200);

        unEscrow.depositTokens(address(token1), 100);
        unEscrow.depositTokens(address(token2), 100);

        assertEq(token1.balanceOf(address(unEscrow)), 100);
    }

    function testWithdrawTokens() public {
        MockERC20 token1 = new MockERC20();
        MockERC20 token2 = new MockERC20();

        address buyer = vm.addr(0x50);
        address seller = vm.addr(0x70);
        token1.mint(buyer, 200);
        token2.mint(buyer, 200);

        vm.startPrank(buyer);
        // approve unEscrow to spend tokens on behalf of buyer
        token1.approve(address(unEscrow), 200);
        unEscrow.depositTokens(address(token1), 100);
        assertEq(token1.balanceOf(address(unEscrow)), 100);
        vm.stopPrank();

        uint256 threedays = 259200;
        skip(threedays + 1); // 3 days in seconds

        vm.prank(seller);
        unEscrow.withdraw(address(token1), buyer, 1);
    }
}
