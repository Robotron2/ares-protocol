// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/modules/AresTimelock.sol";
import "../src/core/AresRegistry.sol";
import "../src/libraries/utils/Errors.sol";

contract AresTimelockTest is Test {
    AresTimelock public timelock;
    AresRegistry public registry;

    address public admin = address(0xAD);
    address public proposer = address(0x69);
    address public participant = address(0x42);
    address public attacker = address(0xBAD);

    bytes32 constant PROPOSER_ID = keccak256("PROPOSER_MODULE");

    function setUp() public {
        registry = new AresRegistry(admin);

        timelock = new AresTimelock(address(registry));

        vm.startPrank(admin);
        registry.registerModule(PROPOSER_ID, proposer);
        registry.setParticipant(participant, true);
        vm.stopPrank();

        vm.deal(address(timelock), 100 ether);
    }

    function test_QueueAndExecuteSuccess() public {
        bytes32 pId = keccak256("proposal_1");
        address target = address(0x123);
        uint256 value = 1 ether;
        bytes memory data = "";

        // Only proposer can queue
        vm.prank(proposer);
        timelock.queue(pId, target, value, data);

        // Move time forward past MIN_DELAY (2 days)
        vm.warp(block.timestamp + 2 days + 1);

        uint256 balanceBefore = target.balance;
        timelock.execute(pId);

        assertEq(target.balance, balanceBefore + 1 ether);
    }

    //Governance Griefing
    function test_Revert_UnauthorizedQueue() public {
        vm.prank(attacker);
        vm.expectRevert(AresErrors.NotProposer.selector);
        timelock.queue(keccak256("steal"), attacker, 1 ether, "");
    }

    //Timelock Bypass
    function test_Revert_PrematureExecution() public {
        bytes32 pId = _setupQueue(1 ether);

        // Move time only 1 day (required 2)
        vm.warp(block.timestamp + 1 days);

        vm.expectRevert(AresErrors.NotReady.selector);
        timelock.execute(pId);
    }

    // --- Helpers ---

    function _setupQueue(uint256 amount) internal returns (bytes32) {
        bytes32 pId = keccak256(abi.encodePacked(block.timestamp));
        vm.prank(proposer);
        timelock.queue(pId, address(0x1), amount, "");
        return pId;
    }
}

