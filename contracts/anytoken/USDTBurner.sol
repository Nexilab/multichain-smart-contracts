// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.10;

import "./USDT.sol";

contract USDTBurner {
    USDT private usdt;

    constructor(address usdtAddress) {
        usdt = USDT(usdtAddress);
    }

    function burn(uint256 amount) external {
        usdt.burn(amount);
    }
}
