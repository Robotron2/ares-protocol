// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import {AresRegistry} from "../src/core/AresRegistry.sol";
import {AresErrors} from "../src/libraries/utils/Errors.sol";

contract AresRegistryTest is Test {
    AresRegistry registry;
    address admin = address(0xAD);
    address user = address(0x01);
    bytes32 constant PROPOSER_ID = keccak256("PROPOSER_MODULE");

    function setUp() public {
        registry = new AresRegistry(admin);
    }

    function test_RegisterModule() public {
        address mockModule = address(0x99);

        vm.prank(admin);
        registry.registerModule(PROPOSER_ID, mockModule);

        assertEq(registry.getModule(PROPOSER_ID), mockModule);
    }

    function test_Fail_NonAdminRegister() public {
        vm.prank(user);
        vm.expectRevert(AresErrors.NotAdmin.selector);
        registry.registerModule(PROPOSER_ID, address(0x66));
    }
}
