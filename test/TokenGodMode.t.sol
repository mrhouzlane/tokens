// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {TokenGodMode} from "../src/TokenGodMode.sol";
import "forge-std/console.sol";

/// @title A token contract with a special address who has God Mode
/// @author Mehdi R.
/// @notice The special address is not the owner
/// @dev
contract TokenGodModeTest is Test{

    TokenGodMode public tokenGodMode;

    function setUp() public {
        address owner = vm.addr(0x20);
        tokenGodMode = new TokenGodMode(owner);
    }

    
   
}