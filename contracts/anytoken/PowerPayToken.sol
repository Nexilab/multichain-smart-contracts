// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract PowerPayTokenNew is ERC20, ERC20Burnable, Pausable, AccessControl, ERC20Permit {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant FREEZE_ROLE = keccak256("FREEZE_ROLE");
    bytes32 public constant PAUSE_MINT_ROLE = keccak256("PAUSE_MINT_ROLE");
    bytes32 public constant PAUSE_BURN_ROLE = keccak256("PAUSE_BURN_ROLE");
    bytes32 public constant PAUSE_TRANSFER_ROLE = keccak256("PAUSE_TRANSFER_ROLE");
    address[] private _frozenAccounts;
    bool private pausedMint;
    bool private pausedBurn;
    bool private pausedTransfer;
    constructor() ERC20("Power Pay", "PowerPay") ERC20Permit("Power Pay") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }
    
    // Modifier to check if an account is frozen
    modifier notFrozen(address account) {
        require(!_isFrozen(account), "Account is frozen");
        _;
    }

    // Check if an account is frozen
    function _isFrozen(address account) internal view returns (bool) {
        for (uint256 i = 0; i < _frozenAccounts.length; i++) {
            if (_frozenAccounts[i] == account) {
                return true;
            }
        }
        return false;
    }

    // Freeze an account
    function freezeAccount(address account) external onlyRole(FREEZE_ROLE) {
        require(!_isFrozen(account), "Account is already frozen");
        _frozenAccounts.push(account);
    }

    // Unfreeze an account
    function unfreezeAccount(address account) external onlyRole(FREEZE_ROLE) {
        for (uint256 i = 0; i < _frozenAccounts.length; i++) {
            if (_frozenAccounts[i] == account) {
                _frozenAccounts[i] = _frozenAccounts[_frozenAccounts.length - 1];
                _frozenAccounts.pop();
                break;
            }
        }
    }
    
     modifier whenNotPauseMint() {
        require(!pausedMint, "mint is paused");
        _;
    }

    function pauseMint() external onlyRole(PAUSE_MINT_ROLE) {
        pausedMint = true;
    }

    function unpauseMint() external onlyRole(PAUSE_MINT_ROLE) {
        pausedMint = false;
    }

    modifier whenNotPauseBurn() {
        require(!pausedMint, "burn is paused");
        _;
    }

    function pauseBurn() external onlyRole(PAUSE_BURN_ROLE) {
        pausedMint = true;
    }

    function unpauseBurn() external onlyRole(PAUSE_BURN_ROLE) {
        pausedMint = false;
    }

    modifier whenNotPauseTransfer() {
        require(!pausedTransfer, "transfer is paused");
        _;
    }

    function pauseTransfer() external onlyRole(PAUSE_TRANSFER_ROLE) {
        pausedTransfer = true;
    }

    function unpauseTransfer() external onlyRole(PAUSE_TRANSFER_ROLE) {
        pausedTransfer = false;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }
    
    function _burn(address from, uint256 amount)
    internal
    whenNotPaused
    whenNotPauseBurn
    virtual override {
        require(from != address(this), "forbid burn from address(this)");
        super._burn(from, amount);
    }
    
    function _mint(address to, uint256 amount)
    internal
    whenNotPaused
    whenNotPauseMint
    virtual override {
        require(to != address(this), "forbid mint to address(this)");
        super._mint(to, amount);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        whenNotPauseTransfer
        override
    {
        require(!_isFrozen(from), "Sender account is frozen");
        super._beforeTokenTransfer(from, to, amount);
    }
}
