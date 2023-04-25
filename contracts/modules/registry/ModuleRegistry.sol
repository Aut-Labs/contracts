//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IModuleRegistry.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ModuleRegistry is IModuleRegistry, Ownable {
    ModuleDefinition[] public modules;

    constructor() {
        _transferOwnership(msg.sender);
        // TODO: put metadata;
        modules.push(ModuleDefinition("", "NonStandaolne"));
        modules.push(ModuleDefinition("", "Onboarding"));
        modules.push(ModuleDefinition("", "Task"));
        modules.push(ModuleDefinition("", "Quest"));
    }

    function addModuleDefinition(
        string calldata metadataURI,
        string calldata name
    ) public onlyOwner override returns (uint) {
        modules.push(ModuleDefinition(metadataURI, name));
    }

    function getAllModules() public view override returns (ModuleDefinition[] memory) {
        return modules;
    }
    function getModuleById(uint moduleId) public view override returns (ModuleDefinition memory) {
        return modules[moduleId];
    }
}
