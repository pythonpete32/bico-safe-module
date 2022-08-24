// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BicoSafeModule.sol";
import "../src/interfaces/IAvatar.sol";

contract BicoSafeModuleTest is Test {
    address safe = 0x8c9Abd867B7773586dB8882f03EF72b6CA36Ec6b;
    address owner1 = 0x000000A5Ff277a5aBf73f2B0580f838E4086b5Aa;
    address owner2 = 0x8BeE0043B5F369367Eb694489305962e72B453b2;

    IAvatar avatar;
    BicoSafeModule bicoModule;

    function setup() public {
        avatar = IAvatar(safe);
        bicoModule = new BicoSafeModule();
        avatar.enableModule(address(bicoModule));
    }
}
