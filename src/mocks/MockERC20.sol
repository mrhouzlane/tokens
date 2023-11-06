// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("MockERC20", "MRC20") {
        _mint(msg.sender, 100);
    }

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }
}
