//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IModule
/// @notice Every module interface should inherite this one. This interface is a standard configuration of a Plugin. Plugins can only be usable if they implement these functions
interface IModule {

    // Custom error used when a certain function in the plugin is not implemented.
    error FunctionNotImplemented();

    /// @notice A plugin contract is deployed for each daoExpander that uses it. When a plugin is associated to a daoExpander, the address is set by the DAOExpander.
    /// @return the address of the daoExpander contract that uses this module.
    function daoExpanderAddress() external view returns (address);

    /// @notice Each plugin implementing a module has a unique name. Name conventions: capitalized snake case, ending with _PLUGIN, example: ERC721_ONBOARDING_PLUGIN
    /// @return a string - the plugin name
    function pluginName() external view returns (string memory);

    /// @notice When a module is added, it's associated with an ID. This ID should be specified in each Plugin implementation.
    /// @return uint256 - the id of the module
    function moduleID() external view returns (uint256);

    /// @notice When a plugin is deployed, the deployer must be set in the constructor. Only the deployer can further on asociate it to a daoExpander.
    /// @return the address of the deployer of the plugin
    function deployer() external view returns (address);

    /// @notice In order for the plugin to have permissions to increase the InteractionIndexer, the plugin must set hasInteractionsDependency to true, otherwise it won't have this access level.
    /// @return the address of the contract that implements IMembershipChecker
    function hasInteractionsDependency() external view returns (bool);
}
