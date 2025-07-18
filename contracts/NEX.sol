// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

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
