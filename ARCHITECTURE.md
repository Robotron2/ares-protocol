# ARES Protocol Architecture

## System Overview

ARES Protocol is a modular treasury execution system designed to enforce delayed governance actions and minimize trust assumptions inside any single contract.

The architecture deliberately splits responsibilities across four modules:

1. **AresProposer**
2. **AresSigner**
3. **AresTimelock**
4. **AresDistributor**

Each module has a single responsibility. No contract manages more than one major subsystem. This keeps the execution flow easier to reason about during audits and reduces the risk of cross-module bugs.

The system is coordinated through a central registry contract which resolves module addresses and tracks governance participants.

---

## Module Responsibilities

### AresProposer

AresProposer manages the proposal lifecycle.  
The proposer contract stores proposals and tracks their lifecycle through a state machine:  
`Pending → Committed → Queued → Executed  `

Governance participants submit proposals describing a transaction:

- target contract
- ETH value
- calldata payload

### A proposal must first be committed, which starts a mandatory delay period before it can be queued for execution. The proposal ID is derived deterministically:

`proposalId = keccak256(target, value, calldata)`

This prevents duplicate proposal spam or griefing attacks where the same action is submitted repeatedly.

---

### AresSigner

AresSigner verifies governance authorization.

The module implements **EIP-712 typed data signatures**. Governance participants sign structured messages that reference a proposal hash.

Verification includes:

- domain separator
- signer nonce
- proposal hash

Each signer has a monotonically increasing nonce stored on-chain. Once a signature is consumed the nonce increments immediately. This prevents replaying the same authorization message.

The module does not maintain voting power or token balances. It only verifies that a registered governance participant authorized the action.

---

### AresTimelock

AresTimelock is the only contract capable of moving treasury funds.

It serves two purposes:

1. Queue governance actions after proposal commit.
2. Execute transactions after a delay.

When a proposal is queued, the contract stores:

- target
- value
- calldata
- executeAfter timestamp

Execution is only allowed once `block.timestamp` exceeds the scheduled execution time.

To mitigate reentrancy risks, the queue entry is deleted **before** the external call is executed. This prevents recursive execution of the same proposal.

The timelock contract also holds treasury ETH and performs the final `call` operation that executes governance actions.

---

### AresDistributor

AresDistributor handles contributor reward distribution.

Instead of storing thousands of reward balances on-chain, the contract stores a single **Merkle root** representing the distribution.

Users claim rewards by submitting:

- index
- account
- amount
- merkle proof

### I used a Merkle distribution to reduce on-chain storage and gas costs. The trade-off is that users must obtain their Merkle proofs off-chain.
