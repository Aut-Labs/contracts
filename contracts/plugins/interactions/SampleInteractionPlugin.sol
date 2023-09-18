//SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.19;

import {SimplePlugin} from "../SimplePlugin.sol";
import {InteractionModifier} from "./InteractionModifier.sol";
import {ILocalReputation} from "./ILocalReputation.sol";

contract SampleInteractionPlugin is SimplePlugin, InteractionModifier {
    uint256 public number;

    constructor(address dao_) SimplePlugin(dao_, 0) InteractionModifier(dao_) {
        number = 1;
    }

    function incrementNumber(string memory x) external isInteraction returns (uint256) {
        number = number + 1;
        return number;
    }

    function incrementNumberPlusOne() external isInteraction returns (uint256) {
        number = number + 1;
        return number;
    }
}
