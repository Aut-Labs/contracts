//SDPX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "hardhat/console.sol";

import {IAutID} from "../../contracts/autid/IAutID.sol";
import {IGlobalParametersAlpha} from "../../contracts/globalParameters/IGlobalParametersAlpha.sol";
import {IPluginRegistry} from "../../contracts/pluginRegistry/IPluginRegistry.sol";
import {INovaRegistry} from "../../contracts/nova/INovaRegistry.sol";
import {GlobalParametersAlpha} from "../../contracts/globalParameters/GlobalParametersAlpha.sol";
import {AutID} from "../../contracts/autid/AutID.sol";
import {NovaRegistry} from "../../contracts/nova/NovaRegistry.sol";
import {Nova} from "../../contracts/nova/Nova.sol";
import {PluginRegistry} from "../../contracts/pluginRegistry/PluginRegistry.sol";
import {AutProxy} from "../../contracts/proxy/AutProxy.sol";

abstract contract DeployHelper {
    error NotImplemented();

    function owner() internal view virtual returns (address) {
        revert NotImplemented();
    }

    function trustedForwarder() internal view virtual returns (address) {
        revert NotImplemented();
    }

    function deploy() internal virtual {
        revert NotImplemented();
    }
}

abstract contract GlobalParametersDeployHelper is DeployHelper {
    IGlobalParametersAlpha private _globalParameters;

    function globalParameters() internal view returns (IGlobalParametersAlpha) {
        return _globalParameters;
    }

    function deploy() internal virtual override {
        address impl = address(new GlobalParametersAlpha());
        address proxy = address(new AutProxy(impl, owner(), ""));
        _globalParameters = IGlobalParametersAlpha(proxy);
    }
}

abstract contract AutIDDeployHelper is DeployHelper {
    IAutID private _autID;

    function autID() internal view returns (IAutID) {
        return _autID;
    }

    function deploy() internal virtual override {
        address impl = address(new AutID(trustedForwarder()));
        address proxy = address(new AutProxy(impl, owner(), abi.encodeWithSelector(AutID.initialize.selector, owner())));
        _autID = IAutID(proxy);
    }
}

abstract contract PluginRegistryDeployHelper is DeployHelper {
    IPluginRegistry private _pluginRegistry;

    function pluginRegistry() internal view returns (IPluginRegistry) {
        return _pluginRegistry;
    }

    function deploy() internal virtual override {
        address impl = address(new PluginRegistry());
        address proxy =
            address(new AutProxy(impl, owner(), abi.encodeWithSelector(IPluginRegistry.initialize.selector, owner())));
        _pluginRegistry = IPluginRegistry(proxy);
    }
}

abstract contract NovaRegistryDeployHelper is AutIDDeployHelper, PluginRegistryDeployHelper {
    INovaRegistry private _novaRegistry;

    function novaRegistry() internal view returns (INovaRegistry) {
        return _novaRegistry;
    }

    function deploy() internal virtual override(AutIDDeployHelper, PluginRegistryDeployHelper) {
        AutIDDeployHelper.deploy();
        PluginRegistryDeployHelper.deploy();

        address novaImpl = address(new Nova());
        address impl = address(new NovaRegistry(trustedForwarder()));
        address proxy = address(
            new AutProxy(
                impl,
                owner(),
                abi.encodeWithSelector(INovaRegistry.initialize.selector, autID(), novaImpl, pluginRegistry())
            )
        );
        _novaRegistry = INovaRegistry(proxy);
    }
}
