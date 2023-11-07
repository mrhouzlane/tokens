// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title A token contract that allows to deposit arbitray ERC20 tokens and withdraw them after a certain time
/// @author Mehdi R.
/// @notice Withdrawal time is only after 3 days after deposit
contract UnEscrow is ReentrancyGuard {
    using SafeERC20 for IERC20;

    mapping(address => mapping(address => DepositDetails)) public escrow; // Mapping between token address and user deposit details
    mapping(address => MarketMaker) public marketMaker;

    enum MarketMaker {
        BUYER,
        SELLER
    }

    struct DepositDetails {
        uint256 amount;
        uint256 depositTime;
    }

    modifier onlyBuyer() {
        require(marketMaker[msg.sender] == MarketMaker.BUYER, "Only buyer can call this function");
        _;
    }

    modifier onlySeller() {
        require(marketMaker[msg.sender] == MarketMaker.SELLER, "Only seller can call this function");
        _;
    }

    constructor(address _buyer, address _seller) {
        marketMaker[_buyer] = MarketMaker.BUYER;
        marketMaker[_seller] = MarketMaker.SELLER;
    }

    function depositTokens(address erc20, uint256 amount) external onlyBuyer {
        escrow[erc20][msg.sender].amount += amount;
        escrow[erc20][msg.sender].depositTime = block.timestamp;
        IERC20(erc20).safeTransferFrom(msg.sender, address(this), amount); // sender = buyer have to give approval to this contract to spend tokens on his behalf
    }

    function withdraw(address erc20, address _depositor, uint256 _amount) external nonReentrant onlySeller {
        require(block.timestamp > 3 days + escrow[erc20][_depositor].depositTime, "Withdraw not allowed yet");
        require(escrow[erc20][_depositor].amount >= _amount);
        escrow[erc20][_depositor].amount -= _amount; // prevent reentrancy by substracting out the deposit amount before making the call
        IERC20(erc20).safeTransfer(msg.sender, _amount);
    }
}
