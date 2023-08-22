// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract TetherUSD is ERC20, ERC20Burnable, Pausable, Ownable, ERC20Permit {
    address[] private _frozenAccounts;
    constructor() ERC20("Tether USD", "USDT") ERC20Permit("Tether USD") {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

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

    function freezeAccount(address account) public onlyOwner {
        require(!_isFrozen(account), "Account is already frozen");
        _frozenAccounts.push(account);
    }

    // Unfreeze an account
    function unfreezeAccount(address account) public onlyOwner {
        for (uint256 i = 0; i < _frozenAccounts.length; i++) {
            if (_frozenAccounts[i] == account) {
                _frozenAccounts[i] = _frozenAccounts[_frozenAccounts.length - 1];
                _frozenAccounts.pop();
                break;
            }
        }
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        require(!_isFrozen(from), "Sender account is frozen");
        super._beforeTokenTransfer(from, to, amount);
    }
}
