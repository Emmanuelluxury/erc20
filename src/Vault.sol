// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ERC20} from "./ERC20.sol";

contract Vault {
    ERC20 public token;
    address public owner;
    uint256 public totalFees;

    constructor(address tokenAddress) {
        token = ERC20(tokenAddress);
        owner = msg.sender;
    }

    mapping(address => uint256) private balances;
    uint256 private _totalDeposits;
    uint256 private _accumulatedFees;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount, uint256 fee);
    event FeesWithdrawn(address indexed owner, uint256 amount);
    event FeeUpdated(uint256 oldFee, uint256 newFee);
    event TotalDepositsUpdated(uint256 newTotalDeposits);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than zero");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        balances[msg.sender] += amount;
        emit Deposited(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Withdraw amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        uint256 fee = (amount * 5) / 100; // 5% fee
        uint256 net = amount - fee;

        balances[msg.sender] -= amount;
        totalFees += fee;
        require(token.transfer(msg.sender, net), "Token transfer failed");

        emit Withdrawn(msg.sender, net, fee);
    }

    function withdrawFees() external onlyOwner {
        require(totalFees > 0, "No fees to withdraw");
        uint256 amount = totalFees;
        totalFees = 0;
        require(token.transfer(owner, amount), "Fee transfer failed");
        emit FeesWithdrawn(owner, amount);
    }

    // Getter functions
    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    function getTotalFees() external view returns (uint256) {
        return totalFees;
    }
}
