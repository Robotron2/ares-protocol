# ARES Protocol

ARES Protocol is a modular treasury execution system designed for governance-controlled funds. The protocol enforces delayed execution, cryptographic authorization, and a strict separation of concerns between governance modules.

The design goal is to keep the system understandable and auditable while still protecting against common governance and treasury attacks.

This repository contains the core implementation and test suite built with **Foundry**.

# System Overview

ARES splits responsibilities across four independent modules:

- **AresProposer** — manages the proposal lifecycle and governance state machine.
- **AresSigner** — verifies cryptographic authorization using EIP-712 signatures.
- **AresTimelock** — holds treasury funds and executes queued proposals after a delay.
- **AresDistributor** — handles scalable contributor rewards via Merkle proofs.

A central **AresRegistry** contract connects these modules. Modules never hardcode each other’s addresses; they resolve them through the registry.

This modular architecture makes the system easier to audit and allows components to be upgraded or replaced independently.

# Repository Structure

src/  
├── core/  
│   └── AresRegistry.sol  
├── interfaces/  
│   ├── IAresDistributor.sol  
│   ├── IAresProposer.sol  
│   ├── IAresRegistry.sol  
│   ├── IAresSigner.sol  
│   └── IAresTimelock.sol  
├── libraries/  
│   ├── AresHashing.sol  
│   ├── AresTypes.sol  
│   └── utils/  
│   ├── Errors.sol  
│   └── Events.sol  
└── modules/  
├── AresDistributor.sol  
├── AresProposer.sol  
├── AresSigner.sol  
└── AresTimelock.sol
