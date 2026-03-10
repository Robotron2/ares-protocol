// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAresTimelock {
    function queue(bytes32 proposalId, address target, uint256 value, bytes calldata data) external;

    function execute(bytes32 proposalId) external payable;
}
