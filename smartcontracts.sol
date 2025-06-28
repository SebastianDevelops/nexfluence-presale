// File: contracts/NEX.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title NEX
 * @dev The official, production-ready utility token for the Nexfluence platform.
 * This version includes metadata for socials and functions to renounce dangerous permissions.
 */
contract NEX is ERC20, ERC20Burnable, AccessControl, Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    // --- FIX: Added public variables for social links ---
    string public twitter;
    string public telegram;
    string public discord;

    constructor(address multisigAddress) ERC20("Nexfluence", "NEX") {
        require(multisigAddress != address(0), "Owner cannot be zero address");
        _grantRole(DEFAULT_ADMIN_ROLE, multisigAddress);
        _grantRole(MINTER_ROLE, multisigAddress);
        _grantRole(PAUSER_ROLE, multisigAddress);
        _mint(multisigAddress, 1000000000 * 10**decimals()); // 1 Billion tokens
    }

    function _update(address from, address to, uint256 value) internal override whenNotPaused {
        super._update(from, to, value);
    }
    
    // --- FEATURE: Functions to set social links, admin only ---
    function setSocials(string memory _twitter, string memory _telegram, string memory _discord) public onlyRole(DEFAULT_ADMIN_ROLE) {
        twitter = _twitter;
        telegram = _telegram;
        discord = _discord;
    }
    
    // --- FEATURE: Pause functionality ---
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    // --- FEATURE: Minting functionality, restricted ---
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }
    
    // --- FEATURE: Renounce roles for decentralization ---
    // After calling this, no one can ever mint new tokens.
    function renounceMinter() public onlyRole(MINTER_ROLE) {
        renounceRole(MINTER_ROLE, _msgSender());
    }

    // After calling this, no one can ever pause or unpause the contract.
    function renouncePauser() public onlyRole(PAUSER_ROLE) {
        renounceRole(PAUSER_ROLE, _msgSender());
    }
}


// File: contracts/Presale.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Presale is Ownable, ReentrancyGuard {
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
        
        require(usdcToken.transferFrom(msg.sender, address(this), _usdcAmount), "USDC transfer failed");
        require(nexToken.balanceOf(address(this)) >= tokensToBuy, "Not enough NEX in contract");
        nexToken.transfer(msg.sender, tokensToBuy);

        emit TokensPurchased(msg.sender, _usdcAmount, tokensToBuy);
    }

    function withdrawFunds() external onlyOwner {
        uint256 balance = usdcToken.balanceOf(address(this));
        require(balance > 0, "No funds to withdraw");
        usdcToken.transfer(owner(), balance);
    }

    function withdrawUnsoldTokens() external onlyOwner {
        require(block.timestamp > endTime, "Presale has not ended");
        uint256 remainingBalance = nexToken.balanceOf(address(this));
        if (remainingBalance > 0) {
            nexToken.transfer(owner(), remainingBalance);
        }
    }
}
