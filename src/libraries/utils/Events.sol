// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library AresEvents {
    event ModuleRegistered(bytes32 indexed id, address module);
    event ParticipantUpdated(address indexed participant, bool allowed);
}
