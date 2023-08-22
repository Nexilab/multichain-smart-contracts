// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../access/PausableControl.sol";

contract PlgchainV1ERC20 is ERC20Capped, ERC20Burnable, AccessControlEnumerable, PausableControl {
    // access control roles
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant FREEZE_ROLE = keccak256("FREEZE_ROLE");

    // pausable control roles
    bytes32 public constant PAUSE_MINT_ROLE = keccak256("PAUSE_MINT_ROLE");
    bytes32 public constant PAUSE_BURN_ROLE = keccak256("PAUSE_BURN_ROLE");
    bytes32 public constant PAUSE_TRANSFER_ROLE = keccak256("PAUSE_TRANSFER_ROLE");

    struct Supply {
        uint256 max; // single limit of each mint
        uint256 cap; // total limit of all mint
        uint256 total; // total minted minus burned
    }

    mapping(address => Supply) public minterSupply;
    address[] private _frozenAccounts;


    uint8 immutable _tokenDecimals;

    event LogSwapin(bytes32 indexed txhash, address indexed account, uint256 amount);
    event LogSwapout(address indexed account, address indexed bindaddr, uint256 amount);

    // Modifier to check if an account is frozen
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

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _cap,
        address _admin
    )
    ERC20(_name, _symbol)
    ERC20Capped(_cap)
    {
        _tokenDecimals = _decimals;
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    function getOwner() external view returns (address) {
        return getRoleMember(DEFAULT_ADMIN_ROLE, 0);
    }

    function decimals() public view virtual override returns (uint8) {
        return _tokenDecimals;
    }

    function underlying() external view virtual returns (address) {
        return address(0);
    }

    function pause(bytes32 role) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause(role);
    }

    function unpause(bytes32 role) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause(role);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        require(!paused(PAUSE_TRANSFER_ROLE), "Token transfer while paused");
        require(!_isFrozen(from), "Sender account is frozen");
        require(!_isFrozen(to), "Recipient account is frozen");
        super._beforeTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal virtual override(ERC20, ERC20Capped) {
        require(to != address(this), "forbid mint to address(this)");
        require(!paused(PAUSE_MINT_ROLE), "mint paused");

        Supply storage s = minterSupply[msg.sender];
        require(amount <= s.max, "minter max exceeded");
        s.total += amount;
        require(s.total <= s.cap, "minter cap exceeded");

        super._mint(to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual override {
        require(from != address(this), "forbid burn from address(this)");
        require(!paused(PAUSE_BURN_ROLE), "burn paused");

        if (hasRole(MINTER_ROLE, msg.sender)) {
            Supply storage s = minterSupply[msg.sender];
            require(s.total >= amount, "minter burn amount exceeded");
            s.total -= amount;
        }

        super._burn(from, amount);
    }

    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) returns (bool) {
        _mint(to, amount);
        return true;
    }

    function burn(address from, uint256 amount) external onlyRole(MINTER_ROLE) returns (bool) {
        _burn(from, amount);
        return true;
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

    function addMinter(address minter, uint256 cap, uint256 max) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(MINTER_ROLE, minter);
        minterSupply[minter].cap = cap;
        minterSupply[minter].max = max;
    }

    function removeMinter(address minter) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(MINTER_ROLE, minter);
        minterSupply[minter].cap = 0;
        minterSupply[minter].max = 0;
    }

    function addFreezer(address freezer) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(FREEZE_ROLE, freezer);
    }

    function removeFreezer(address freezer) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(FREEZE_ROLE, freezer);
    }

    function setMinterCap(address minter, uint256 cap) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(hasRole(MINTER_ROLE, minter), "not minter");
        minterSupply[minter].cap = cap;
    }

    function setMinterMax(address minter, uint256 max) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(hasRole(MINTER_ROLE, minter), "not minter");
        minterSupply[minter].max = max;
    }

    function setMinterTotal(address minter, uint256 total, bool force) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(force || hasRole(MINTER_ROLE, minter), "not minter");
        minterSupply[minter].total = total;
    }
}

contract PlgchainV1ERC20WithUnderlying is PlgchainV1ERC20 {
    using SafeERC20 for IERC20;

    address public immutable override underlying;

    event Deposit(address indexed from, address indexed to, uint256 amount);
    event Withdraw(address indexed from, address indexed to, uint256 amount);

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _cap,
        address _admin,
        address _underlying
    ) PlgchainV1ERC20(_name, _symbol, _decimals, _cap, _admin) {
        require(_underlying != address(0), "underlying is the zero address");
        require(_underlying != address(this), "underlying is same to address(this)");
        require(_decimals == IERC20Metadata(_underlying).decimals(), "decimals mismatch");

        underlying = _underlying;
    }

    function deposit(uint256 amount) public returns (uint256) {
        return deposit(amount, msg.sender);
    }

    function deposit(uint256 amount, address to) public returns (uint256) {
        IERC20(underlying).safeTransferFrom(msg.sender, address(this), amount);
        _mint(to, amount);
        emit Deposit(msg.sender, to, amount);
        return amount;
    }

    function withdraw(uint256 amount) public returns (uint256) {
        return withdraw(amount, msg.sender);
    }

    function withdraw(uint256 amount, address to) public returns (uint256) {
        _burn(msg.sender, amount);
        IERC20(underlying).safeTransfer(to, amount);
        emit Withdraw(msg.sender, to, amount);
        return amount;
    }
}

contract TTToken is PlgchainV1ERC20 {
    constructor() PlgchainV1ERC20("TTToken", "TT", 18, 500_000_000_000 * 10 ** 18, 0x1c8324C3a750b9D9Ff6e677aC8FD08eB7E9960dc){
    }
}
