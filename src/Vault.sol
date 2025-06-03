// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC20} from "./ERC20.sol";

contract Vault {
    ERC20 public token;
    address public owner;
    uint256 public totalFees;

    mapping(address => uint256) private balances;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount, uint256 fee);
    event FeesWithdrawn(address indexed owner, uint256 amount);

    constructor(address _token) {
        token = ERC20(_token);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");
        token.transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
        emit Deposited(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        uint256 fee = (amount * 5) / 100; // 5% fee
        uint256 withdrawAmount = amount - fee;

        balances[msg.sender] -= amount;
        totalFees += fee;

        token.transfer(msg.sender, withdrawAmount);
        emit Withdrawn(msg.sender, withdrawAmount, fee);
    }

    function withdrawFees() external onlyOwner {
        require(totalFees > 0, "No fees to withdraw");
        uint256 feesToWithdraw = totalFees;
        totalFees = 0;
        token.transfer(owner, feesToWithdraw);
        emit FeesWithdrawn(owner, feesToWithdraw);
    }

    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    function getTotalFees() external view returns (uint256) {
        return totalFees;
    }
}
