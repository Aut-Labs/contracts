//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IModuleRegistry {
    struct ModuleDefinition {
        string metadataURI;
        string name;
        bool isStandalone;
    }

    function addModuleDefinition(string calldata metadataURI, string calldata name, bool isStandalone)
        external
        returns (uint);

    function getAllModules()
        external
        view
        returns (ModuleDefinition[]  memory);

    function getModuleById(uint moduleID)
        external
        view
        returns (ModuleDefinition memory);
}
