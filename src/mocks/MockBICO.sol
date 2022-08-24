// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC20} from "solmate/tokens/ERC20.sol";

contract MockBICO is ERC20 {
    constructor() ERC20("BICO", "BICO", 18) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
