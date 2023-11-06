// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {TokenWithSanctions} from "../src/TokenWithSanctions.sol";
import {MockERC1363Receiver} from "../src/mocks/MockReceiver.sol";
import {MockERC1363Spender} from "../src/mocks/MockSpender.sol";
import "forge-std/console.sol";

contract TokenWithSanctionsTest is Test {
    TokenWithSanctions public tokenWithSanctions;

    function setUp() public {
        address owner = vm.addr(0x20);
        emit log_address(owner);
        tokenWithSanctions = new TokenWithSanctions(owner);
    }

    function testSupply() public {
        assertEq(tokenWithSanctions.totalSupply(), 20 ether);
        emit log_named_uint("totalSupply", tokenWithSanctions.totalSupply() / (10 ** 18));
    }

    function testMint() public {
        // setup
        vm.prank(vm.addr(0x20));
        address alice = vm.addr(0x10);

        // Alice mint
        tokenWithSanctions.mint(alice, 1 ether);

        assertEq(tokenWithSanctions.balanceOf(alice), 1 ether);
        emit log_named_uint("balanceOf", tokenWithSanctions.balanceOf(alice) / (10 ** 18));
    }

    function testFail_Mint() public {
        vm.prank(vm.addr(0x01));
        address alice = vm.addr(0x10);

        // Minter is not the owner
        vm.expectRevert("CALLER_NOT_OWNER");
        tokenWithSanctions.mint(alice, 1 ether);
    }

    function testBanUser() public {
        vm.prank(0x32E77DE0D74a5C7AF861aAEd324c6a4c488142a8);

        // Ban Alice
        address[] memory _addresses = new address[](1);
        _addresses[0] = vm.addr(0x10);

        tokenWithSanctions.banUser(_addresses);

        bool ban = tokenWithSanctions.banned(_addresses[0]);
        assertEq(ban, true, "expect Alice to be banned");
    }

    function testFail_NotOwner() public {
        // Ban Alice
        address[] memory _addresses = new address[](1);
        _addresses[0] = vm.addr(0x10);

        // Address of the caller is not the owner
        vm.prank(vm.addr(0x10));
        vm.expectRevert("CALLER_NOT_OWNER");
        tokenWithSanctions.banUser(_addresses);
    }

    function testFail_BannedCannotMint() public {
        // Ban ALICE
        vm.startPrank(0x32E77DE0D74a5C7AF861aAEd324c6a4c488142a8);

        // Ban Alice
        address[] memory _addresses = new address[](1);
        _addresses[0] = vm.addr(0x14);
        tokenWithSanctions.banUser(_addresses);
        vm.stopPrank();

        // Alice cannot mint anymore
        vm.prank(vm.addr(0x14));
        vm.expectRevert("BANNED USER CANNOT MINT");
        tokenWithSanctions.mint(vm.addr(0x14), 1 ether);
    }

    function testTransferToERC1363Receiver() public {
        address owner = vm.addr(0x20);
        MockERC1363Receiver mockReceiver = new MockERC1363Receiver();
        address receiver = address(mockReceiver);

        vm.startPrank(owner);
        tokenWithSanctions.mint(owner, 2 ether);
        assertEq(tokenWithSanctions.balanceOf(owner), 22 ether);
        vm.stopPrank();

        vm.startPrank(owner);
        tokenWithSanctions.transferAndCall(receiver, 1 ether, "This is your salary");
        vm.stopPrank();

        assertEq(tokenWithSanctions.balanceOf(receiver), 1 ether);
    }

    function testFail_TransferToBannedAddress() public {
        address owner = vm.addr(0x20);
        address alice = vm.addr(0x10);
        MockERC1363Receiver mockReceiver = new MockERC1363Receiver();
        address receiver = address(mockReceiver);

        vm.startPrank(owner);
        tokenWithSanctions.mint(alice, 2 ether);
        assertEq(tokenWithSanctions.balanceOf(alice), 2 ether);
        vm.stopPrank();

        // Ban Alice
        vm.startPrank(owner);
        address[] memory _addresses = new address[](1);
        _addresses[0] = alice;
        tokenWithSanctions.banUser(_addresses);
        vm.stopPrank();

        vm.startPrank(alice);
        vm.expectRevert("BANNED USER CANNOT TRANSFER");
        tokenWithSanctions.transfer(receiver, 1 ether);
        vm.stopPrank();
    }

    function testFail_TransferToBannedReceiver() public {
        address owner = vm.addr(0x20);
        MockERC1363Receiver mockReceiver = new MockERC1363Receiver();
        address receiver = address(mockReceiver);

        // Ban ERC1363-RECEIVER
        vm.startPrank(owner);
        address[] memory _addresses = new address[](1);
        _addresses[0] = receiver;
        tokenWithSanctions.banUser(_addresses);
        vm.stopPrank();

        vm.startPrank(owner);
        vm.expectRevert("BANNED ERC1363-RECEIVER CANNOT RECEIVER");
        tokenWithSanctions.transfer(receiver, 1 ether);
        vm.stopPrank();
    }

    function testTransfer() public {
        address owner = vm.addr(0x20);
        address receiver = vm.addr(0x99);

        vm.startPrank(owner);
        tokenWithSanctions.transfer(receiver, 1 ether);
        vm.stopPrank();

        assertEq(tokenWithSanctions.balanceOf(receiver), 1 ether);
    }

    function testFail_transferERC20() public {
        address owner = vm.addr(0x20);
        address receiver = vm.addr(0x99);

        // Ban Simple Receiver (ERC20)
        vm.startPrank(owner);
        address[] memory _addresses = new address[](1);
        _addresses[0] = receiver;
        tokenWithSanctions.banUser(_addresses);
        vm.stopPrank();

        vm.startPrank(owner);
        vm.expectRevert("BANNED USER CANNOT RECEIVE ");
        tokenWithSanctions.transfer(receiver, 1 ether);
        vm.stopPrank();
    }

    function testFail_TransferFromSenderBanned() public {
        address Bob = vm.addr(40);
        address owner = vm.addr(0x20);
        address Alice = vm.addr(0x10);

        vm.startPrank(owner);
        tokenWithSanctions.mint(Bob, 2 ether);
        assertEq(tokenWithSanctions.balanceOf(Bob), 2 ether);
        address[] memory _addresses = new address[](1);
        _addresses[0] = Bob;
        tokenWithSanctions.banUser(_addresses);
        vm.stopPrank();

        vm.startPrank(Bob);
        vm.expectRevert("BANNED USER CANNOT TRANSFER");
        tokenWithSanctions.transfer(Alice, 1 ether);
        vm.stopPrank();
    }

    function testApproveAndCall() public {
        address owner = vm.addr(0x20);
        MockERC1363Receiver mockReceiver = new MockERC1363Receiver();
        address receiver = address(mockReceiver);
        MockERC1363Spender mockSpender = new MockERC1363Spender();
        address spender = address(mockSpender);

        vm.startPrank(owner);
        tokenWithSanctions.approveAndCall(spender, 2 ether);
        assertEq(tokenWithSanctions.allowance(owner, spender), 2 ether);
        vm.stopPrank();
        vm.prank(spender); // spender sends tokens on behalf of owner to receiver
        tokenWithSanctions.transferFromAndCall(owner, receiver, 1 ether);
    }

    function testFuzz_TransferAndCall(uint64 amount) public {
        address owner = vm.addr(0x20);
        vm.startPrank(owner);
        tokenWithSanctions.mint(owner, 90000000000000000000 ether);
        MockERC1363Receiver mockReceiver = new MockERC1363Receiver();
        address receiver = address(mockReceiver);
        tokenWithSanctions.transferAndCall(receiver, amount);
    }
}
