// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAresProposer {
    function commitProposal(address target, uint256 value, bytes calldata data) external returns (bytes32);

    function queueProposal(bytes32 proposalId) external;

    function cancelProposal(bytes32 proposalId) external;

    function state(bytes32 proposalId) external view returns (uint8);
}
