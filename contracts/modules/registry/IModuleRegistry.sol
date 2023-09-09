//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * @title IModuleRegistry
 * @notice Interface for the ModuleRegistry contract, which is responsible for managing the modules available for Aut DAOs.
 * Modules are represented by metadata and an ID and can only be added by the Aut Team.
 * DAOs can activate and install specific plugins from the available modules.
 *
 */
interface IModuleRegistry {
    /**
     * @dev Emitted when a new module definition is added to the registry
     * @param id the ID of the newly added module definition
     */
    event ModuleDefinitionAdded(uint256 id);
    /**
     * @dev Structure representing a module definition in the registry
     * @param metadataURI the metadata URI for the module
     * @param id the ID of the module
     */

    struct ModuleDefinition {
        string metadataURI;
        uint256 id;
    }

    /**
     * @notice Adds a new module definition to the registry
     * @dev Only the owner can call this function
     * @param metadataURI the metadata URI for the module being added
     * @return the ID of the newly added module definition
     */
    function addModuleDefinition(string calldata metadataURI) external returns (uint256);

    /**
     * @notice Returns an array of all module definitions in the registry
     * @return an array of ModuleDefinition structs
     */
    function getAllModules() external view returns (ModuleDefinition[] memory);

    /**
     * @notice Returns the module definition for the given module ID
     * @param moduleID the ID of the module
     * @return the ModuleDefinition struct for the given module ID
     */
    function getModuleById(uint256 moduleID) external view returns (ModuleDefinition memory);

    /**
     * @notice Updates the metadata URI for a given module ID
     * @dev Only the owner can call this function
     * @param moduleId the ID of the module to update
     * @param uri the new metadata URI for the module
     */
    function updateMetadataURI(uint256 moduleId, string calldata uri) external;
}
