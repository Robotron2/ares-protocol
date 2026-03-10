// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library AresEvents {
    event ModuleRegistered(bytes32 indexed id, address module);
    event ParticipantUpdated(address indexed participant, bool allowed);
    event Queued(bytes32 indexed id, uint256 executeAfter);
    event Executed(bytes32 indexed id);
    event ProposalCommitted(bytes32 indexed proposalId, address proposer);
    event ProposalQueued(bytes32 indexed proposalId);
    event ProposalCancelled(bytes32 indexed proposalId);
    event SignatureUsed(address indexed signer, bytes32 proposalHash);
}
