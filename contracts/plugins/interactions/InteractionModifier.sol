// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "../SimplePlugin.sol";
import {ILocalReputation} from "./ILocalReputation.sol";
import {INova} from "../../nova/interfaces/INova.sol";
import {IPluginRegistry} from "../registry/IPluginRegistry.sol";
import {IPlugin} from "../../plugins/IPlugin.sol";

/// @title Local Reputation isInteraction Plugin Modifier
/// @notice Design to add local reputation capability to plugin
/// @dev can only be used as a modifier within an instantiation of SimplePlugin
/// @author parseb
abstract contract InteractionModifier {
    ILocalReputation ILR;
    address private _deployer_;
    address lastLocalRepUsed;

    error AuthorityExpected();

    constructor(address dao_) {
        ILR = ILocalReputation(IPluginRegistry(INova(dao_).pluginRegistry()).defaultLRAddr());
        ILR.initialize(dao_);
    }

    event LocalRepALogChangedFor(address nova, address repAlgo);

    modifier isInteraction() {
        _;
        ILR.interaction(msg.data, _msgSender());
    }

    function changeInUseLocalRep(address NewLocalRepAlgo_) public virtual {
        if (_msgSender() != _deployer_) revert AuthorityExpected();
        ILR = ILocalReputation(NewLocalRepAlgo_);

        emit LocalRepALogChangedFor(IPlugin(address(this)).daoAddress(), NewLocalRepAlgo_);
    }

    function lastReputationAddr() external view returns (address) {
        return lastLocalRepUsed;
    }

    function currentReputationAddr() external view returns (address) {
        return address(ILR);
    }

    /// @dev msg.sender might not be the intended target overriding assumed if the case
    function _msgSender() internal virtual returns (address) {
        return msg.sender;
    }
}
