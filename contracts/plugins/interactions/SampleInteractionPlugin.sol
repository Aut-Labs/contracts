
//SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.18;

import {SimplePlugin} from "../SimplePlugin.sol";
import {InteractionModifier} from "./InteractionModifier.sol";

contract SampleInteractionPlugin is SimplePlugin, InteractionModifier {


    uint256 public number;


    constructor(address dao_, address localReputationAlgo_)
        SimplePlugin(dao_, 0) 
        InteractionModifier(dao_, localReputationAlgo_ ) {

        }


    function incrementNumber() external isInteraction returns (uint256) {
        number +=1;
        return number;
    }



}


