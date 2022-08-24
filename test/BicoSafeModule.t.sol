// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {Test} from "forge-std/Test.sol";
import {TestAvatar} from "../src/mocks/TestAvatar.sol";
import {MockBICO} from "../src/mocks/MockBICO.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

import {BicoSafeModule} from "../src/BicoSafeModule.sol";
import {BicoVesting} from "../src/mocks/BicoVesting.sol";

contract BicoSafeModuleTest is Test {
    address deployer = address(0xB055);

    address safe = 0x8c9Abd867B7773586dB8882f03EF72b6CA36Ec6b;
    address owner1 = 0x000000A5Ff277a5aBf73f2B0580f838E4086b5Aa;
    address owner2 = 0x8BeE0043B5F369367Eb694489305962e72B453b2;

    uint256 vestAmount = 119999997000000000000000;
    uint256 unlockAmount = 13333333000000000000000;
    uint64 unlockTime = 1638378000;
    uint64 startTime = 1654102800;
    uint64 endTime = 1717261200;

    // IAvatar avatar;
    BicoSafeModule bicoModule;
    BicoVesting vesting;
    MockBICO bico;
    TestAvatar avatar;

    function setUp() public {
        avatar = new TestAvatar();
        bicoModule = new BicoSafeModule(address(this));
        bico = new MockBICO();
        vesting = new BicoVesting(address(bico));

        // set up vesting contract
        // bico.mint(address(this), vestAmount);
        bico.approve(address(vesting), 100000000 * 10**18);
        // bico.transfer(address(vesting), vestAmount - unlockAmount);
        vesting.createClaim(
            address(avatar),
            vestAmount,
            unlockAmount,
            unlockTime,
            startTime,
            endTime
        );

        // setup safe
        bicoModule.setAvatar(address(avatar));
        bicoModule.setTarget(address(avatar));
        avatar.enableModule(address(bicoModule));
    }

    function testSetup() public {
        assertEq(address(bicoModule.avatar()), address(avatar));
        assertEq(address(bicoModule.target()), address(avatar));
        assertEq(avatar.isModuleEnabled(address(bicoModule)), true);
    }
}
