// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/ERC20.sol";

contract ERC20Test is Test {
    ERC20 token;
    address Cornelius = address(0x123);
    address Odumeje = address(0x124);
    uint8 constant DECIMALS = 18;
    uint256 constant TOTALSUPPLY = 1000000 * (10 ** DECIMALS);

    function setUp() public {
        token = new ERC20("MyToken", "MTK", DECIMALS, TOTALSUPPLY);
    }

    function testInitialSupply() public view {
        assertEq(token.name(), "MyToken");
        assertEq(token.symbol(), "MTK");
        assertEq(token.totalSupply(), TOTALSUPPLY);
        assertEq(token.decimals(), DECIMALS);
    }

    function testTransfer() public {
        uint256 amount = 200;
        token.transfer(Cornelius, amount);

        assertEq(token.balanceOf(address(this)), TOTALSUPPLY - amount);
        assertEq(token.balanceOf(Cornelius), amount);

        console.log(token.balanceOf(address(this)));
        console.log(token.balanceOf(Cornelius));
    }

    function testApproveAndTransferFrom() public {
        uint256 amount = 2 * (10 ** DECIMALS);
        token.approve(Cornelius, amount);
        assertEq(token.allowance(address(this), Cornelius), amount);

        vm.prank(Cornelius);
        token.transferFrom(address(this), Odumeje, amount);

        assertEq(token.balanceOf(Odumeje), amount);
        assertEq(token.balanceOf(address(this)), TOTALSUPPLY - amount);
        assertEq(token.balanceOf(Cornelius), 0);
    }

    function testMint() public {
        uint256 amount = 5 * (10 ** DECIMALS);
        address Emmanuel = address(0x125);
        token.mint(Emmanuel, amount);
        assertEq(token.balanceOf(Emmanuel), amount);
        assertEq(token.totalSupply(), TOTALSUPPLY + amount);
    }

    function testBurn() public {
        uint256 amount = 5 * (10 ** DECIMALS);
        token.burn(amount);
        assertEq(token.balanceOf(address(this)), TOTALSUPPLY - amount);
    }
}
