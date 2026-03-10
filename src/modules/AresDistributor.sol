// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {IAresRegistry} from "../interfaces/IAresRegistry.sol";

import {AresErrors} from "../libraries/utils/Errors.sol";
import {AresEvents} from "../libraries/utils/Events.sol";

contract AresDistributor {
    IAresRegistry public registry;

    bytes32 public merkleRoot;

    mapping(uint256 => bool) public isClaimed;

    modifier onlyTimelock() {
        address timelock = registry.getModule(keccak256("TIMELOCK_MODULE"));
        if (msg.sender != timelock) revert AresErrors.NotTimelock();
        _;
    }

    constructor(address _registry) {
        registry = IAresRegistry(_registry);
    }

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata proof) external {
        if (isClaimed[index]) revert AresErrors.AlreadyClaimed();

        bytes32 leaf = keccak256(abi.encodePacked(index, account, amount));

        if (!MerkleProof.verify(proof, merkleRoot, leaf)) {
            revert AresErrors.InvalidProof();
        }

        isClaimed[index] = true;

        (bool success,) = payable(account).call{value: amount}("");
        require(success, "ETH_TRANSFER_FAILED");

        emit AresEvents.Claimed(index, account, amount);
    }

    function updateRoot(bytes32 newRoot) external onlyTimelock {
        merkleRoot = newRoot;

        emit AresEvents.RootUpdated(newRoot);
    }

    receive() external payable {}
}
