//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IModuleRegistry.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ModuleRegistry is IModuleRegistry, Ownable {
    ModuleDefinition[] public modules;

    constructor() {
        _transferOwnership(msg.sender);
        // TODO: put metadata;
        modules.push(ModuleDefinition("none", "NONE"));
        modules.push(ModuleDefinition("onboarding uri", "Onboarding"));
        modules.push(ModuleDefinition("task uri", "Task"));
        modules.push(ModuleDefinition("quest uri", "Quest"));
    }

    function addModuleDefinition(
        string calldata metadataURI,
        string calldata name
    ) public onlyOwner override returns (uint) {
        require(bytes(metadataURI).length > 0, 'invalid uri');
        require(bytes(name).length > 0, 'invalid name');
        uint id = modules.length;
        modules.push(ModuleDefinition(metadataURI, name));
        emit ModuleDefinitionAdded(id);
        return id;
    }

    function getAllModules() public view override returns (ModuleDefinition[] memory) {
        return modules;
    }
    function getModuleById(uint moduleId) public view override returns (ModuleDefinition memory) {
        return modules[moduleId];
    }
}
