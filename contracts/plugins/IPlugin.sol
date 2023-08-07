//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "../modules/IModule.sol";

/**
 * @title IPlugin
 * @notice This interface defines the standard configuration of a plugin. Every plugin interface should inherit this interface.
 */
interface IPlugin is IModule {

    /**
     * @notice Returns the address of the deployer of the plugin
     * @return The address of the deployer of the plugin
     */
    function deployer() external view returns (address);
    
    /**
     * @notice Sets the plugin ID for the current plugin instance
     * @param tokenId The ID of the plugin instance to be set
     */
    function setPluginId(uint256 tokenId) external;

    /**
     * @notice Returns the ID of the current plugin instance
     * @return The ID of the current plugin instance
     */
    function pluginId() external view returns (uint);

}
