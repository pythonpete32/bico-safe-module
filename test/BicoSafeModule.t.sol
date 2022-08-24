// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BicoSafeModule.sol";
import "../src/mocks/BicoVesting.sol";
import "zodiac/test/TestAvatar.sol";

contract BicoSafeModuleTest is Test {
    address safe = 0x8c9Abd867B7773586dB8882f03EF72b6CA36Ec6b;
    address owner1 = 0x000000A5Ff277a5aBf73f2B0580f838E4086b5Aa;
    address owner2 = 0x8BeE0043B5F369367Eb694489305962e72B453b2;

    uint256 vestAmount = 119999997000000000000000;
    uint256 unlockAmount = 13333333000000000000000;
    uint256 unlockTime = 1638378000;
    uint256 startTime = 1654102800;
    uint256 endTime = 1717261200;

    // IAvatar avatar;
    BicoSafeModule bicoModule;
    BicoVesting vesting;
    MockERC20 bico;
    TestAvatar avatar;

    function setup() public {
        avatar = new TestAvatar();
        bicoModule = new BicoSafeModule();
        bico = new MockERC20("Bico", "BICO", 18);
        vesting = new BicoVesting(address(bico));

        // set up vesting contract
        bico.mint(address(vesting), 119999997000000000000000);
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
}
