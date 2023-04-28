//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../modules/IModule.sol";

/// @title IModule
/// @notice Every module interface should inherite this one. This interface is a standard configuration of a Plugin. Plugins can only be usable if they implement these functions
interface IPlugin is IModule {

    /// @notice When a plugin is deployed, the deployer must be set in the constructor. Only the deployer can further on asociate it to a daoExpander.
    /// @return the address of the deployer of the plugin
    function deployer() external view returns (address);
    
    function setPluginId(uint256 tokenId) external;

    function pluginId() external view returns (uint);

}
