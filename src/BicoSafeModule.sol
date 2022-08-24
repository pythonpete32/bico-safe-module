// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./safe-contracts/common/Enum.sol";

interface GnosisSafe {
    /// @dev Allows a Module to execute a Safe transaction without any further confirmations.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction.
    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    ) external returns (bool success);
}

contract BicoSafeModule {
    // 1. call claim on the vesting contract
    // 2. call claim on the staking contract
    // 3. call skate BICO in the vault
}
