// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library AresErrors {
    error NotAdmin();
    error InvalidAddress();
    error ModuleAlreadySet();
    error NotProposer();
    error NotReady();
    error NotQueued();
    error NotParticipant();
    error ProposalExists();
    error InvalidState();
    error CommitDelayNotElapsed();
}
