// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IAresRegistry} from "../interfaces/IAresRegistry.sol";
import {AresErrors} from "../libraries/utils/Errors.sol";
import {AresEvents} from "../libraries/utils/Events.sol";

contract AresRegistry is IAresRegistry {
    address public admin;

    mapping(bytes32 => address) private modules;
    mapping(address => bool) private participants;

    modifier onlyAdmin() {
        _onlyAdmin();
        _;
    }

    constructor(address _admin) {
        if (_admin == address(0)) revert AresErrors.InvalidAddress();
        admin = _admin;
    }

    function registerModule(bytes32 id, address module) external onlyAdmin {
        if (module == address(0)) revert AresErrors.InvalidAddress();
        if (modules[id] != address(0)) revert AresErrors.ModuleAlreadySet();

        modules[id] = module;

        emit AresEvents.ModuleRegistered(id, module);
    }

    function setParticipant(address user, bool allowed) external onlyAdmin {
        participants[user] = allowed;

        emit AresEvents.ParticipantUpdated(user, allowed);
    }

    function getModule(bytes32 id) external view returns (address) {
        return modules[id];
    }

    function isParticipant(address user) external view returns (bool) {
        return participants[user];
    }

    function _onlyAdmin() internal view {
        if (msg.sender != admin) revert AresErrors.NotAdmin();
    }
}
