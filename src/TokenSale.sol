// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Token sale and buyback with bonding curve
/// @author Mehdi R.
/// @notice The more tokens a user buys, the more expensive the token becomes
/// @dev This contract inherits from ERC20 and Ownable2Step

contract TokenSale is Ownable2Step, ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public constant START_PRICE = 1 ether; // Starting price for the first token
    uint256 public constant PRICE_INCREMENT = 0.1 ether; // Price increment for each additional token
    uint256 public reserveBalance;
    mapping(address => uint256) private balances; // Balance of RS token for each user.

    event TokenSold(address buyer, uint256 amount, uint256 pricePaid);
    event TokenBought(uint256 amount, uint256 priceReceived);

    error InsufficientPayment(uint256 payment, uint256 required);

    constructor(address initialOwner, string memory tokenName, string memory tokenSymbol)
        ERC20(tokenName, tokenSymbol)
        Ownable(initialOwner)
    {}

    ///@notice Buy token with reserve token
    ///@dev The price of the token is calculated using liquidTokenPrice()
    ///@dev Contract receives eth in exchange of tokens for the buyer.
    function buyToken(uint256 _qty) external payable {
        uint256 totalPrice = calculatePrice() * _qty;
        if (msg.value < totalPrice) {
            revert InsufficientPayment(msg.value, totalPrice);
        }

        // State changes before external calls
        _mint(msg.sender, _qty); // Mint new tokens for the buyer
        reserveBalance += totalPrice;
        balances[msg.sender] += _qty;
        emit TokenSold(msg.sender, _qty, totalPrice);

        // Refund
        if (msg.value > totalPrice) {
            payable(msg.sender).transfer(msg.value - totalPrice);
        }
    }

    ///@notice Selling tokens back to the contract
    ///@dev The price of the token is calculated using calculatePrice()
    ///@param _qty The amount of tokens to sell back
    function buyBack(uint256 _qty) external nonReentrant {
        require(balanceOf(msg.sender) >= _qty, "Not enough tokens");
        uint256 ethAmount = calculatePrice() * _qty;
        require(reserveBalance >= ethAmount, "Not enough reserve balance to buy back");
        balances[msg.sender] -= _qty;
        reserveBalance -= ethAmount; // Update the reserve balance
        _burn(msg.sender, _qty); // reduce supply
        payable(msg.sender).transfer(ethAmount); // transfer ETH to the seller
    }

    ///@notice Withdraw reserve tokens from the contract
    ///@dev Only the owner can withdraw the reserve tokens
    ///@param _receiver The address to receive the reserve tokens
    function withdraw(address _receiver) external onlyOwner returns (bool) {
        IERC20(address(this)).safeTransferFrom(address(this), _receiver, balanceOf(address(this)));
        return true;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /// @notice Linear bonding curve Price calculation
    function calculatePrice() public view returns (uint256) {
        return START_PRICE + (totalSupply() * PRICE_INCREMENT);
    }
}
