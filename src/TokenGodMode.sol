// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

/// @title A token contract with a special address who has God Mode
/// @author Mehdi R.
/// @notice The special address is not the owner
/// @dev
contract TokenGodMode is Ownable2Step, ERC20 {
    address public specialAddress;
    uint256 public initialsupply;

    constructor(address initialOwner) ERC20("RareSkills", "RSK") Ownable(initialOwner) {
        _mint(initialOwner, 20 ether);
    }

    function setSpecialAddress(address _specialAddr) external onlyOwner {
        require(_specialAddr != address(0), "TokenGodMode: special address is the zero address");
        specialAddress = _specialAddr;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        if (msg.sender == specialAddress || msg.sender == owner()) {
            _approve(msg.sender, spender, amount);
        } else {
            address owner = msg.sender;
            _approve(owner, spender, amount);
        }
        return true;
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
