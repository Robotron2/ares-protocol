// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IAresRegistry} from "../interfaces/IAresRegistry.sol";
import {AresErrors} from "../libraries/utils/Errors.sol";
import {AresEvents} from "../libraries/utils/Events.sol";

contract AresTimelock is ReentrancyGuard {
    uint256 public constant MAX_WITHDRAW_BPS = 1000;
    uint256 public constant BPS_DENOMINATOR = 10000;
    uint256 public constant MIN_DELAY = 2 days;

    IAresRegistry public registry;

    struct QueueItem {
        address target;
        uint256 value;
        bytes data;
        uint256 executeAfter;
    }

    mapping(bytes32 => QueueItem) public queuedTransactions;
    mapping(bytes32 => bool) public vetoed;

    modifier onlyProposer() {
        _onlyProposer();
        _;
    }

    constructor(address _registry) {
        registry = IAresRegistry(_registry);
    }

    receive() external payable {}

    function queue(bytes32 id, address target, uint256 value, bytes calldata data) external onlyProposer {
        if (value > (address(this).balance * MAX_WITHDRAW_BPS) / BPS_DENOMINATOR) {
            revert AresErrors.WithdrawLimitExceeded();
        }
        queuedTransactions[id] =
            QueueItem({target: target, value: value, data: data, executeAfter: block.timestamp + MIN_DELAY});

        emit AresEvents.Queued(id, block.timestamp + MIN_DELAY);
    }

    function execute(bytes32 id) external nonReentrant {
        QueueItem memory item = queuedTransactions[id];

        if (vetoed[id]) revert AresErrors.NotReady();

        if (item.executeAfter == 0) revert AresErrors.NotQueued();

        if (block.timestamp < item.executeAfter) {
            revert AresErrors.NotReady();
        }

        delete queuedTransactions[id];

        (bool ok,) = item.target.call{value: item.value}(item.data);

        require(ok);

        emit AresEvents.Executed(id);
    }

    function veto(bytes32 id) external {
        if (!registry.isParticipant(msg.sender)) revert AresErrors.NotParticipant();

        vetoed[id] = true;

        emit AresEvents.ProposalVetoed(id);
    }

    function _onlyProposer() internal view {
        address proposer = registry.getModule(keccak256("PROPOSER_MODULE"));
        if (msg.sender != proposer) revert AresErrors.NotProposer();
    }
}
