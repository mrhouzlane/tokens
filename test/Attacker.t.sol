// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.19;

// import {Test, console2} from "forge-std/Test.sol";
// import {Attacker} from "../src/Attacker.sol";
// import {TokenSale} from "../src/TokenSale.sol";
// import "forge-std/console.sol";

// contract AttackerTest is Test {
//     Attacker public attacker;
//     TokenSale public tokenSale;

//     function setUp() public {
//         address owner = vm.addr(0x20);
//         tokenSale = new TokenSale(owner, "Test", "TST");
//         attacker = new Attacker(tokenSale);
//     }

//     function testFail_Attack() public {
//         address owner = vm.addr(0x20);
//         address malicious = vm.addr(0x21);

//         vm.deal(malicious, 100 ether);
//         vm.deal(address(tokenSale), 500 ether);

//         vm.prank(owner);
//         tokenSale.mint(owner, 1);
//         vm.expectRevert("Not enough ETH - Reserve Balance protection");
//         attacker.attack{value: 2 ether}(1, 1);
//     }

// }
