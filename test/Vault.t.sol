
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/Vault.sol";
import "../src/ERC20.sol";

contract VaultTest is Test {
    Vault  vault;
    ERC20 token;
    address user = address(1);
    address owner;

    function setUp() public {
        owner = address(this);
        token = new ERC20("Test Token", "TST", 18, 1_000_000 ether);
        vault = new Vault(address(token));

        // Give user some tokens and approve the vault
        token.transfer(user, 1000 ether);
        vm.prank(user);
        token.approve(address(vault), 1000 ether);
    }

    function testDeposit() public {
        vm.prank(user);
        vault.deposit(100 ether);
        assertEq(vault.getBalance(user), 100 ether);
    }

    function testWithdrawWithFee() public {
        vm.prank(user);
        vault.deposit(200 ether);

        vm.prank(user);
        vault.withdraw(100 ether);

        // 5% of 100 = 5 fee, user should get 95
        assertEq(token.balanceOf(user), 1000 ether - 200 ether + 95 ether);
        assertEq(vault.getBalance(user), 100 ether); // 200 - 100 withdrawn
        assertEq(vault.getTotalFees(), 5 ether);
    }

    function testWithdrawFees() public {
        vm.prank(user);
        vault.deposit(200 ether);

        vm.prank(user);
        vault.withdraw(100 ether);

        vault.withdrawFees();
        assertEq(token.balanceOf(owner), 1_000_000 ether - 1000 ether + 5 ether);
    }

    function testOnlyOwnerCanWithdrawFees() public {
        vm.prank(user);
        vault.deposit(100 ether);
        vm.prank(user);
        vault.withdraw(100 ether);

        vm.prank(user);
        vm.expectRevert("Not the contract owner");
        vault.withdrawFees();
    }
}
