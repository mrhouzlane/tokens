## **ERC777 and ERC1363** 

What problems do ERC777 and ERC1363 solves ? 


- Use same concept of sending ether for erc20 tokens - provides equivalent of msg.value for tokens. 
    - send(dest, value, data)
- Receive hooks :   
    - function that is called on a contract when the contract receives tokens. 



``` interface ERC777TokensRecipient {
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;
} ```
