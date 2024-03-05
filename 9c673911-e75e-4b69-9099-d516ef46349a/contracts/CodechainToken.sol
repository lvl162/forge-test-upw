// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Token has 18 decimal places
contract CodechainToken is Ownable, ERC20 {
    // **********************************************************
    // ************************** Token *************************
    // **********************************************************

    using SafeERC20 for IERC20;

    uint256 tokenSupply = 300000000 * 10 ** 18;
    // 38.7% of 300m is 116.1m
    uint256 tokensForPresale = 116100000 * 10 ** 18;

    constructor(
        address initialOwner
    ) ERC20("Codechain", "CODE") Ownable(initialOwner) {
        // Mint the pre-sale supply to contract
        _mint(address(this), tokensForPresale);
        // Send the rest to the contract creator
        _mint(initialOwner, tokenSupply - tokensForPresale);
    }

    // **********************************************************
    // ************************ Pre-sale ************************
    // **********************************************************

    bool public presale = true;

    uint256 presaleTotal = 0;
    uint256 distributionPerUnit;
    uint256 presaleMultiplier = 1075; // Represents 1.075

    mapping(address => uint256) public presaleBalances;

    function deposit() external payable {
        require(presale == true, "Presale ended");
        require(msg.value >= 0.1 ether, "Minimum contribution is 0.1 ETH");

        uint256 amount = (msg.value * presaleMultiplier) / 1000;

        presaleBalances[msg.sender] += amount;
        presaleTotal += amount;
    }

    function claim(address userAddress) external {
        require(presale == false, "Presale ongoing");

        uint256 claimable = presaleBalances[userAddress];
        require(claimable > 0, "No funds to claim");

        presaleBalances[userAddress] = 0;

        uint256 tokensToSend = claimable * distributionPerUnit;

        IERC20(address(this)).safeTransfer(userAddress, tokensToSend);
    }

    function withdraw(uint256 amount) external onlyOwner {
        // Codechain Vault Address
        payable(0xf8852e9217cA1A3201b7D1D836f34B0C90dD01dE).transfer(amount);
    }

    function setPresaleMultiplier(uint256 multiplier) external onlyOwner {
        require(
            presaleMultiplier > multiplier,
            "New multiplier must be smaller than previous"
        );
        require(presaleMultiplier > 1000, "Multiplier cannot be negative");

        presaleMultiplier = multiplier;
    }

    function endPresale() external onlyOwner {
        require(presale == true, "Presale already ended");
        distributionPerUnit = tokensForPresale / presaleTotal;
        presale = false;
    }
}
