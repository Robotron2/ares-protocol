// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library AresTypes {
    enum ProposalState {
        Pending,
        Committed,
        Queued,
        Executed,
        Cancelled
    }

    enum ActionType {
        Transfer,
        Call,
        Upgrade
    }
}
