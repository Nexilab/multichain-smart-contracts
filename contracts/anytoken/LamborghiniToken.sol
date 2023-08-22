// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../access/PausableControl.sol";

contract LamborghiniToken is Initializable,ERC20Upgradeable,ERC20BurnableUpgradeable,PausableUpgradeable,AccessControlUpgradeable, UUPSUpgradeable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant FREEZE_ROLE = keccak256("FREEZE_ROLE");
    bytes32 public constant PAUSE_MINT_ROLE = keccak256("PAUSE_MINT_ROLE");
    bytes32 public constant PAUSE_BURN_ROLE = keccak256("PAUSE_BURN_ROLE");
    bytes32 public constant PAUSE_TRANSFER_ROLE = keccak256("PAUSE_TRANSFER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    address[] private _frozenAccounts;
    bool private pausedMint;
    bool private pausedBurn;
    bool private pausedTransfer;
    event LogSwapin(bytes32 indexed txhash, address indexed account, uint256 amount);
    event LogSwapout(address indexed account, address indexed bindaddr, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __ERC20_init("Lamborghini", "LMBR");
        __ERC20Burnable_init();
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(FREEZE_ROLE, msg.sender);
        _grantRole(PAUSE_MINT_ROLE, msg.sender);
        _grantRole(PAUSE_BURN_ROLE, msg.sender);
        _grantRole(PAUSE_TRANSFER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
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

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _mint(address to, uint256 amount)
    internal
    whenNotPaused
    whenNotPauseMint
    virtual override {
        require(to != address(this), "forbid mint to address(this)");
        super._mint(to, amount);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) returns (bool) {
        _mint(to, amount);
    }

    function _burn(address from, uint256 amount)
    internal
    whenNotPaused
    whenNotPauseBurn
    virtual override {
        require(from != address(this), "forbid burn from address(this)");
        super._burn(from, amount);
    }

    function burn(address from, uint256 amount) external onlyRole(MINTER_ROLE) returns (bool) {
        _burn(from, amount);
        return true;
    }

    function addMinter(address minter, uint256 cap, uint256 max) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(MINTER_ROLE, minter);
    }

    function removeMinter(address minter) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(MINTER_ROLE, minter);
    }

    function addFreezer(address freezer) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(FREEZE_ROLE, freezer);
    }

    function removeFreezer(address freezer) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(FREEZE_ROLE, freezer);
    }

    function Swapin(bytes32 txhash, address account, uint256 amount) external onlyRole(MINTER_ROLE) returns (bool) {
        _mint(account, amount);
        emit LogSwapin(txhash, account, amount);
        return true;
    }

    function Swapout(uint256 amount, address bindaddr) external returns (bool) {
        require(bindaddr != address(0), "zero bind address");
        _burn(msg.sender, amount);
        emit LogSwapout(msg.sender, bindaddr, amount);
        return true;
    }


    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        require(!_isFrozen(from), "Sender account is frozen");
        super._beforeTokenTransfer(from, to, amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {}
}
