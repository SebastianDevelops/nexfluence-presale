// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Presale is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable nexToken;
    IERC20 public immutable usdcToken;
    uint256 public constant TOKEN_PRICE_IN_CENTS = 5; // $0.05
    uint256 public hardCapInUsdc;
    uint256 public usdcRaised;
    uint256 public startTime;
    uint256 public endTime;

    event TokensPurchased(address indexed purchaser, uint256 amountUsdc, uint256 amountTokens);

    constructor(
        address _nexTokenAddress,
        address _usdcTokenAddress,
        uint256 _hardCapInUsdc,
        uint256 _durationInDays,
        address initialOwner
    ) Ownable(initialOwner) {
        nexToken = IERC20(_nexTokenAddress);
        usdcToken = IERC20(_usdcTokenAddress);
        hardCapInUsdc = _hardCapInUsdc * (10 ** 6); // USDC has 6 decimals
        startTime = block.timestamp;
        endTime = block.timestamp + (_durationInDays * 1 days);
    }

    function buyTokens(uint256 _usdcAmount) external nonReentrant {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Presale is not active");
        require(_usdcAmount > 0, "USDC amount must be positive");
        require(usdcRaised + _usdcAmount <= hardCapInUsdc, "Hard cap exceeded");

        uint256 tokensToBuy = (_usdcAmount * (10**18)) / (TOKEN_PRICE_IN_CENTS * 10000);
        usdcRaised += _usdcAmount;

        usdcToken.safeTransferFrom(msg.sender, address(this), _usdcAmount);
        require(nexToken.balanceOf(address(this)) >= tokensToBuy, "Not enough NEX in contract");
        nexToken.safeTransfer(msg.sender, tokensToBuy);

        emit TokensPurchased(msg.sender, _usdcAmount, tokensToBuy);
    }

    function withdrawFunds() external onlyOwner {
        uint256 balance = usdcToken.balanceOf(address(this));
        require(balance > 0, "No funds to withdraw");
        usdcToken.safeTransfer(owner(), balance);
    }

    function withdrawUnsoldTokens() external onlyOwner {
        require(block.timestamp > endTime, "Presale has not ended");
        uint256 remainingBalance = nexToken.balanceOf(address(this));
        if (remainingBalance > 0) {
            nexToken.safeTransfer(owner(), remainingBalance);
        }
    }
}
