//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IModuleRegistry {
    event ModuleDefinitionAdded(uint id);

    struct ModuleDefinition {
        string metadataURI;
        string name;
    }

    function addModuleDefinition(
        string calldata metadataURI,
        string calldata name
    ) external returns (uint);

    function getAllModules() external view returns (ModuleDefinition[] memory);

    function getModuleById(
        uint moduleID
    ) external view returns (ModuleDefinition memory);
}
