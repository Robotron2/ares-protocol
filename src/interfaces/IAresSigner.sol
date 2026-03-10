// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAresSigner {
    function authorize(address signer, bytes32 proposalHash, bytes calldata signature) external returns (bool);
}
