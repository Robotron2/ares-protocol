// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAresRegistry {
    function registerModule(bytes32 id, address module) external;

    function getModule(bytes32 id) external view returns (address);

    function isParticipant(address user) external view returns (bool);
}
