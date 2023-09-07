// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "../SimplePlugin.sol";
import {ILocalReputation} from "./ILocalReputation.sol";
// import {IPlugin} from "../IPlugin.sol";

/// @title Local Reputation isInteraction Plugin Modifier
/// @notice Design to add local reputation capability to plugin
/// @dev can only be used as a modifier within an instantiation of SimplePlugin
/// @author parseb
abstract contract InteractionModifier {
    ILocalReputation ILR;

    constructor(address dao_, address localReputationAlgo_) {
        ILR = ILocalReputation(localReputationAlgo_);
        ILR.initialize(dao_);
    }

    modifier isInteraction() {
        _;
        ILR.interaction(msg.data, _msgSender());
    }

    /// @dev msg.sender might not be the intended target overriding assumed if the case
    function _msgSender() internal virtual returns (address) {
        return msg.sender;
    }
}
