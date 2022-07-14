// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Web3BridgeDonation is Ownable{

    error InvalidAmount();

    error InvalidAddress();

    error InsufficientBalance(uint balance, uint withdrawAmount);

    IERC20 Token;

    event Donation(address indexed donor, uint amount);

    function donateNativeToken() payable public returns(bool){
        if(msg.value <= 0){
            revert InvalidAmount();
        }
        emit Donation(msg.sender, msg.value);
        return true;
    }

    function donate(address tokenAddress,uint amount) external returns(bool){
        if(tokenAddress == address(0)){
            revert InvalidAddress();
        }
        Token = IERC20(tokenAddress);
        Token.transferFrom(msg.sender, address(this), amount);
        emit Donation(msg.sender, amount);
        return true;
    }

    function withdrawNative() public payable onlyOwner returns(bool){
        uint amount = address(this).balance;
        payable(_msgSender()).transfer(amount);
        return true;
    }

    function withdraw(address tokenAddress, uint amount) external onlyOwner returns(bool){
        Token = IERC20(tokenAddress);
        uint balance = Token.balanceOf(address(this));
        if(balance < amount){
            revert InsufficientBalance({balance: balance, withdrawAmount: amount});
        }
        Token.transfer(_msgSender(), amount);
        return true;
    }
}