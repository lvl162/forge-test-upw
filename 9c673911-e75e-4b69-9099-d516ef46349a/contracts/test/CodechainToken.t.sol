// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../CodechainToken.sol";

contract CodechainTokenTest is Test {
    CodechainToken codechainToken;
    address owner;
    address user1;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        codechainToken = new CodechainToken(owner);
    }

    function testInitialTokenDistribution() public {
        // Initial token distribution checks
        uint256 totalSupply = codechainToken.totalSupply();
        assertEq(totalSupply, 300000000 * 10 ** 18, "Total supply mismatch");

        uint256 ownerBalance = codechainToken.balanceOf(owner);
        uint256 expectedOwnerBalance = (300000000 - 116100000) * 10 ** 18;
        assertEq(ownerBalance, expectedOwnerBalance, "Owner balance mismatch");

        uint256 contractBalance = codechainToken.balanceOf(
            address(codechainToken)
        );
        assertEq(
            contractBalance,
            116100000 * 10 ** 18,
            "Contract balance mismatch"
        );
    }

    function testPresaleDeposit() public {
        // Activate this to test transactions that require ether
        vm.deal(user1, 1 ether);

        // Simulate user1 sending 0.1 ether
        vm.startPrank(user1);
        codechainToken.deposit{value: 0.1 ether}();
        vm.stopPrank();

        // Verify user's presale balance
        uint256 expectedBalance = (0.1 ether * 1075) / 1000;
        assertEq(
            codechainToken.presaleBalances(user1),
            expectedBalance,
            "Presale balance mismatch"
        );
    }
}
