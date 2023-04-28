//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IModuleRegistry {
    event ModuleDefinitionAdded(uint id);

    struct ModuleDefinition {
        string metadataURI;
        uint id;
    }

    function addModuleDefinition(
        string calldata metadataURI
    ) external returns (uint);

    function getAllModules() external view returns (ModuleDefinition[] memory);

    function getModuleById(
        uint moduleID
    ) external view returns (ModuleDefinition memory);

    function updateMetadataURI(uint moduleId, string calldata uri) external;
}
