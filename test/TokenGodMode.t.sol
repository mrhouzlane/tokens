// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {TokenGodMode} from "../src/TokenGodMode.sol";
import "forge-std/console.sol";

/// @title A token contract with a special address who has God Mode
/// @author Mehdi R.
/// @notice The special address is not the owner
/// @dev
contract TokenGodModeTest is Test {
    TokenGodMode public tokenGodMode;

    function setUp() public {
        address owner = vm.addr(0x20);
        tokenGodMode = new TokenGodMode(owner);
    }

    function testOwnerBalanceAfterDeploy() public {
        address owner = vm.addr(0x20);
        assertTrue(tokenGodMode.balanceOf(owner) == 20 ether);
    }

    function testFail_setSpecialAddressNotOwner() public {
        address randomUser = vm.addr(0x50);
        address specialAddress = vm.addr(0x21);

        vm.startPrank(randomUser);
        vm.expectRevert(bytes("CALLER_NOT_OWNER"));
        tokenGodMode.setSpecialAddress(specialAddress);
        vm.stopPrank();
    }

    function testTransferPower() public {
        address owner = vm.addr(0x20);
        address specialAddress = vm.addr(0x21);
        console.log(tokenGodMode.balanceOf(owner));
        console.log(tokenGodMode.balanceOf(address(tokenGodMode)));
        address Alice = vm.addr(0x22);

        vm.startPrank(owner);
        tokenGodMode.setSpecialAddress(specialAddress);
        assertTrue(tokenGodMode.specialAddress() == specialAddress);
        tokenGodMode.transferFrom(owner, specialAddress, 2 ether);
        assertTrue(tokenGodMode.balanceOf(specialAddress) == 2 ether);
        tokenGodMode.transferFrom(specialAddress, Alice, 1 ether);
        vm.stopPrank();
    }

    function testFail_TransferWithoutPower() public {
        address owner = vm.addr(0x20);
        address random = vm.addr(0x50);
        address alice = vm.addr(0x32);

        vm.prank(owner);
        tokenGodMode.transferFrom(owner, random, 2 ether);
        vm.startPrank(random);
        vm.expectRevert(bytes("CALLER_DOES_NOT_HAVE_POWER"));
        tokenGodMode.transferFrom(random, alice, 1 ether);
        vm.stopPrank();
    }

    function testWithApprovalTransferWithoutPower() public {
        address owner = vm.addr(0x20);
        address random = vm.addr(0x50);
        address alice = vm.addr(0x32);

        vm.prank(owner);
        tokenGodMode.transferFrom(owner, random, 2 ether);
        vm.startPrank(random);
        tokenGodMode.approve(random, 1 ether);
        tokenGodMode.transferFrom(random, alice, 1 ether);
        vm.stopPrank();
    }

    function testFail_AllowanceLow() public {
        address owner = vm.addr(0x20);
        address random = vm.addr(0x50);
        address alice = vm.addr(0x32);

        vm.prank(owner);
        tokenGodMode.transferFrom(owner, random, 2 ether);
        vm.startPrank(random);
        tokenGodMode.approve(random, 1 ether);
        vm.expectRevert(bytes("ALLOWANCE_TOO_LOW"));
        tokenGodMode.transferFrom(random, alice, 2 ether);
        vm.stopPrank();
    }
}
