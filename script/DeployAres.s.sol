// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";

import {AresRegistry} from "../src/core/AresRegistry.sol";
import {AresProposer} from "../src/modules/AresProposer.sol";
import {AresSigner} from "../src/modules/AresSigner.sol";
import {AresTimelock} from "../src/modules/AresTimelock.sol";
import {AresDistributor} from "../src/modules/AresDistributor.sol";

contract DeployAres is Script {
    bytes32 constant PROPOSER_MODULE = keccak256("PROPOSER_MODULE");
    bytes32 constant SIGNER_MODULE = keccak256("SIGNER_MODULE");
    bytes32 constant TIMELOCK_MODULE = keccak256("TIMELOCK_MODULE");
    bytes32 constant DISTRIBUTOR_MODULE = keccak256("DISTRIBUTOR_MODULE");

    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address admin = vm.addr(deployerKey);

        vm.startBroadcast(deployerKey);

        //Deploy
        AresRegistry registry = new AresRegistry(admin);

        //Deploy Modules
        AresProposer proposer = new AresProposer(address(registry));
        AresSigner signer = new AresSigner(address(registry));
        AresTimelock timelock = new AresTimelock(address(registry));
        AresDistributor distributor = new AresDistributor(address(registry));

        //Register Modules
        registry.registerModule(PROPOSER_MODULE, address(proposer));
        registry.registerModule(SIGNER_MODULE, address(signer));
        registry.registerModule(TIMELOCK_MODULE, address(timelock));
        registry.registerModule(DISTRIBUTOR_MODULE, address(distributor));

        vm.stopBroadcast();
    }
}
