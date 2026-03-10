// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library AresHashing {
    function proposalId(address target, uint256 value, bytes calldata data) internal pure returns (bytes32) {
        return keccak256(abi.encode(target, value, data));
    }
}
