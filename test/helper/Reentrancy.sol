// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AresTimelock} from "../../src/modules/AresTimelock.sol";

contract ReentrantAttacker {
    address public timelock;

    constructor(address _timelock) {
        timelock = _timelock;
    }

    function attack(bytes32 id) external {
        AresTimelock(payable(msg.sender)).execute(id);
    }

    receive() external payable {}
}
