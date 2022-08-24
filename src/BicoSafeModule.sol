// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "safe-contracts/common/Enum.sol";
import {IAvatar} from "./interfaces/IAvatar.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract BicoSafeModule is Owned {
    /*///////////////////////////////////////////////////////////////
                            ERRORS
    //////////////////////////////////////////////////////////////*/

    error ClaimBicoFailed();
    error StakeBicoFailed();

    /*///////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @dev Emitted each time the avatar is set.
    event AvatarSet(address indexed previousAvatar, address indexed newAvatar);
    /// @dev Emitted each time the Target is set.
    event TargetSet(address indexed previousTarget, address indexed newTarget);
    /// @dev Emitted when BICO token is set
    event BicoSet(address indexed bico);
    /// @dev Emitted when Vesting contract is set
    event VestingSet(address indexed vesting);
    /// @dev Emitted when BICO is claimed
    event ClaimedBico(uint256 amount);
    /// @dev Emitted when BICO is staked
    event StakedBico(uint256 amount);

    /*///////////////////////////////////////////////////////////////
                            STORAGE
    //////////////////////////////////////////////////////////////*/

    /// @dev Address that will ultimately execute function calls.
    address public avatar;
    /// @dev Address that this module will pass transactions to.
    address public target;
    /// @dev BICO token address
    ERC20 public bico;
    /// @dev Vesting contract address
    address public vesting;

    /*///////////////////////////////////////////////////////////////
                            INITIALIZATION
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) Owned(_owner) {}

    /// @dev Set up the module
    /// @notice This function must be called before the module can be used.
    /// @param _avatar Address that will ultimately execute function calls.
    /// @param _bico BICO token address
    /// @param _vesting Vesting contract address
    function setupModule(
        address _avatar,
        address _bico,
        address _vesting
    ) external onlyOwner {
        require(_avatar != address(0), "BicoSafeModule: avatar cannot be zero");
        setAvatar(_avatar);
        setTarget(_avatar);
        vesting = _vesting;
        bico = ERC20(_bico);
        emit AvatarSet(address(0), _avatar);
        emit TargetSet(address(0), _avatar);
        emit BicoSet(_bico);
        emit VestingSet(_vesting);
    }

    /*///////////////////////////////////////////////////////////////
                            ADMIN ACTIONS
    //////////////////////////////////////////////////////////////*/

    /// @dev Sets the avatar to a new avatar (`newAvatar`).
    /// @notice Can only be called by the current owner.
    function setAvatar(address _newAvatar) public onlyOwner {
        address previousAvatar = avatar;
        avatar = _newAvatar;
        emit AvatarSet(previousAvatar, _newAvatar);
    }

    /// @dev Sets the target to a new target (`newTarget`).
    /// @notice Can only be called by the current owner.
    function setTarget(address _newTarget) public onlyOwner {
        address previousTarget = target;
        target = _newTarget;
        emit TargetSet(previousTarget, _newTarget);
    }

    /*///////////////////////////////////////////////////////////////
                            USER ACTIONS
    //////////////////////////////////////////////////////////////*/

    /// @dev Call claim on the vesting contract
    /// @notice Can be called by any address.
    function claimBico() public {
        uint256 balanceBefore = bico.balanceOf(address(avatar));
        (, bytes memory data) = avatar.call(abi.encodeWithSignature("claim()"));
        bool sucess = exec(target, 0, data, Enum.Operation.Call);
        if (!sucess) revert ClaimBicoFailed();
        uint256 balanceAfter = bico.balanceOf(address(avatar));
        emit ClaimedBico(balanceAfter - balanceBefore);
    }

    /// @dev Stake BICO tokens
    /// @notice Can be called by any address.
    function stakeBico() public {
        uint256 balanceBefore = bico.balanceOf(address(avatar));
        (, bytes memory data) = avatar.call(
            abi.encodeWithSignature(
                "stake(address,amount)",
                avatar,
                bico.balanceOf(address(avatar))
            )
        );
        bool sucess = exec(target, 0, data, Enum.Operation.Call);
        if (!sucess) revert StakeBicoFailed();
        uint256 balanceAfter = bico.balanceOf(address(avatar));
        emit StakedBico(balanceBefore - balanceAfter);
    }

    /*///////////////////////////////////////////////////////////////
                            INTERNAL LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @dev Passes a transaction to be executed by the avatar.
    /// @notice Can only be called by this contract.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction: 0 == call, 1 == delegate call.
    function exec(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) internal returns (bool success) {
        success = IAvatar(target).execTransactionFromModule(
            to,
            value,
            data,
            operation
        );

        return success;
    }

    /// @dev Passes a transaction to be executed by the target and returns data.
    /// @notice Can only be called by this contract.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction: 0 == call, 1 == delegate call.
    function execAndReturnData(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) internal returns (bool success, bytes memory returnData) {
        (success, returnData) = IAvatar(target)
            .execTransactionFromModuleReturnData(to, value, data, operation);

        return (success, returnData);
    }
}
