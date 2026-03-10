// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IAresRegistry.sol";
import "../interfaces/IAresTimelock.sol";
import "../libraries/AresHashing.sol";
import "../libraries/AresTypes.sol";

import {AresErrors} from "../libraries/utils/Errors.sol";
import {AresEvents} from "../libraries/utils/Events.sol";

contract AresProposer {
    uint256 public constant COMMIT_DELAY = 1 days;

    IAresRegistry public registry;

    struct Proposal {
        address target;
        uint256 value;
        bytes data;
        uint256 commitTimestamp;
        AresTypes.ProposalState state;
    }

    mapping(bytes32 => Proposal) public proposals;

    modifier onlyParticipant() {
        if (!registry.isParticipant(msg.sender)) revert AresErrors.NotParticipant();
        _;
    }

    constructor(address _registry) {
        registry = IAresRegistry(_registry);
    }

    function commitProposal(address target, uint256 value, bytes calldata data)
        external
        onlyParticipant
        returns (bytes32 id)
    {
        id = AresHashing.proposalId(target, value, data);

        if (proposals[id].commitTimestamp != 0) revert AresErrors.ProposalExists();

        proposals[id] = Proposal({
            target: target,
            value: value,
            data: data,
            commitTimestamp: block.timestamp,
            state: AresTypes.ProposalState.Committed
        });

        emit AresEvents.ProposalCommitted(id, msg.sender);
    }

    function queueProposal(bytes32 id) external {
        Proposal storage p = proposals[id];

        if (p.state != AresTypes.ProposalState.Committed) revert AresErrors.InvalidState();

        if (block.timestamp < p.commitTimestamp + COMMIT_DELAY) {
            revert AresErrors.CommitDelayNotElapsed();
        }

        address timelock = registry.getModule(keccak256("TIMELOCK_MODULE"));

        IAresTimelock(timelock).queue(id, p.target, p.value, p.data);

        p.state = AresTypes.ProposalState.Queued;

        emit AresEvents.ProposalQueued(id);
    }

    function cancelProposal(bytes32 id) external onlyParticipant {
        Proposal storage p = proposals[id];

        if (p.state == AresTypes.ProposalState.Executed) {
            revert AresErrors.InvalidState();
        }

        p.state = AresTypes.ProposalState.Cancelled;

        emit AresEvents.ProposalCancelled(id);
    }

    function state(bytes32 id) external view returns (uint8) {
        return uint8(proposals[id].state);
    }
}
