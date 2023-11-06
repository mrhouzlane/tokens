// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MockERC1363Receiver} from "./mocks/MockReceiver.sol";
import "erc1363-payable-token/contracts/token/ERC1363/ERC1363.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title TokenWithSanctions
/// @author Mehdi Rhouzlane
/// @notice Fungible token that allows an admin to ban specified addresses from sending and receiving tokens.
/// @dev This token inherites from ERC1363 and Ownable2Step and integrates a mock ERC1363 receiver.

// TO DO : Add custom errors

contract TokenWithSanctions is ERC1363, Ownable2Step, MockERC1363Receiver {
    mapping(address => bool) public banned;

    constructor(address intialOwner) ERC20("RSK", "RareSkills") Ownable(intialOwner) {
        _mint(intialOwner, 20 ether);
    }

    ///@notice Mints the specified amount of tokens to the specified address
    ///@dev reverts if the sender is not the owner
    ///@param _to The address to mint to
    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }

    ///@notice Bans the specified addresses
    ///@dev reverts if the sender is not the owner
    ///@param _address The addresses to ban
    function banUser(address[] calldata _address) external onlyOwner {
        uint256 l = _address.length;
        for (uint256 i = 0; i < l; i++) {
            banned[_address[i]] = true;
        }
    }

    /// @inheritdoc ERC20
    function transfer(address to, uint256 value) public override(ERC20, IERC20) returns (bool) {
        checkBlacklisted(to);
        return super.transfer(to, value);
    }

    /// @inheritdoc ERC1363
    function transferAndCall(address to, uint256 value, bytes memory _data) public override returns (bool) {
        checkBlacklisted(to);
        return super.transferAndCall(to, value, _data);
    }

    function approveAndCall(address spender, uint256 value) public override returns (bool) {
        return approveAndCall(spender, value, "");
    }

    /// @notice Checks if the sender and the recipient are banned
    /// @dev reverts if the sender is banned
    /// @dev reverts if the recipient is banned
    /// @dev msg.sender is the sender
    /// @param to The recipient address
    function checkBlacklisted(address to) internal view {
        require(!banned[msg.sender], "Sender is banned");
        require(!banned[to], "Recipient is banned");
    }
}
