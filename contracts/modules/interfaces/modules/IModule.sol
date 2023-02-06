//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IModule
/// @notice Every module interface should inherite this one. This interface is a standard configuration of a Plugin. Plugins can only be usable if they implement these functions
interface IModule {

    // Custom error used when a certain function in the plugin is not implemented.
    error FunctionNotImplemented();

    /// @notice A plugin contract is deployed for each daoExpander that uses it. When a plugin is associated to a daoExpander, the address is set by the DAOExpander.
    /// @return the address of the daoExpander contract that uses this module.
    function daoAddress() external view returns (address);

    /// @notice When a plugin is deployed, the deployer must be set in the constructor. Only the deployer can further on asociate it to a daoExpander.
    /// @return the address of the deployer of the plugin
    function deployer() external view returns (address);

    function isActive() external view returns(bool);
}
