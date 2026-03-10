// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAresDistributor {
    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata merkleProof) external;

    function updateRoot(bytes32 newRoot) external;
}
