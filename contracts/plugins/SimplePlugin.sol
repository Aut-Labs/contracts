//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./IPlugin.sol";
import "./registry/IPluginRegistry.sol";
import "../components/interfaces/get/INovaModules.sol";

/**
 * @title SimplePlugin
 * @notice An abstract contract that implements the IPlugin interface and provides common functionality to all plugins
 */
abstract contract SimplePlugin is IPlugin {
    address _deployer;
    address _novaAddress;

    uint256 public override pluginId;
    uint256 public override moduleId;

    bool public override isActive;
    address public pluginRegistry;

    /**
     * @notice A modifier that checks if the caller is a module installed in the Nova
     * @dev The function must use `_` before the require statement to execute the function body before checking the require condition
     */
    //// @dev
    modifier onlyNovaModule() {
        uint256[] memory installedPlugins = IPluginRegistry(pluginRegistry).getPluginIdsByNova(_novaAddress);
        bool pluginFound = false;
        for (uint256 i = 0; i < installedPlugins.length; i++) {
            if (installedPlugins[i] == pluginId) pluginFound = true;
            _;
        }
        require(pluginFound, "Only Nova Module");
        _;
    }

    /**
     * @notice A modifier that checks if the caller is the deployer of the plugin
     */
    modifier onlyDeployer() {
        require(msg.sender == _deployer, "Only deployer can call this function");
        _;
    }

    /**
     * @notice A modifier that checks if the caller is the owner of the plugin
     */
    modifier onlyOwner() {
        require(msg.sender == owner(), "Only owner can call this function");
        _;
    }

    /**
     * @notice A modifier that checks if the caller is the plugin registry contract
     */
    modifier onlyPluginRegistry() {
        require(msg.sender == pluginRegistry, "Only plugin registry");
        _;
    }

    /**
     * @notice Initializes the contract with the provided Nova and module ID
     * @param Nova The address of the Nova
     * @param modId The module ID of the plugin
     */
    constructor(address Nova, uint256 modId) {
        _novaAddress = Nova;
        pluginRegistry = INovaModules(Nova).pluginRegistry();
        _deployer = msg.sender;
        moduleId = modId;
    }

    /**
     * @notice Returns the owner of the plugin
     * @return The address of the owner
     */
    function owner() public view returns (address) {
        return IPluginRegistry(pluginRegistry).getOwnerOfPlugin(address(this));
    }

    /**
     * @notice Returns the address of the deployer of the plugin
     * @return The address of the deployer
     */
    function deployer() public view override returns (address) {
        return _deployer;
    }

    /**
     * @notice Returns the address of the Nova the plugin is associated with
     * @return The address of the Nova
     */
    function novaAddress() public view override returns (address) {
        return _novaAddress;
    }

    /**
     * @notice Sets the `isActive` state variable to `newActive`
     * @param newActive The new state of the `isActive` variable
     */
    function _setActive(bool newActive) internal {
        isActive = newActive;
    }

    /**
     * @notice Sets the plugin ID of the plugin
     * @dev Only callable by the plugin registry contract
     * @param tokenId The ID of the plugin
     */
    function setPluginId(uint256 tokenId) public override onlyPluginRegistry {
        pluginId = tokenId;
    }
}
