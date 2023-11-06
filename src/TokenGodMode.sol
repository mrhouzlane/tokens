// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

/// @title A token contract with a special address who has God Mode
/// @author Mehdi R.
/// @notice The special address is not the owner
/// @dev
contract TokenGodMode is Ownable2Step, ERC20 {
    address public specialAddress;

    constructor(address initialOwner) ERC20("RSK", "RareSkills") Ownable(initialOwner) {
        _mint(initialOwner, 20 ether);
    }

    function setSpecialAddress(address _specialAddr) internal onlyOwner {
        specialAddress = _specialAddr;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        if (msg.sender == specialAddress || msg.sender == owner()) {
            _transfer(from, to, value);
        } else {
            address spender = msg.sender;
            _spendAllowance(from, spender, value);
            _transfer(from, to, value);
        }
        return true;
    }
}
