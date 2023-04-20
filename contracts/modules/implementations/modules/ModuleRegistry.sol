//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interfaces/modules/IModuleRegistry.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ModuleRegistry is IModuleRegistry, Ownable {
    ModuleDefinition[] public modules;

    constructor() {
        _transferOwnership(msg.sender);
        // TODO: put metadata;
        modules.push(ModuleDefinition("", "", false));
        modules.push(ModuleDefinition("", "Onboarding", true));
        modules.push(ModuleDefinition("", "OnboardingTasks", false));
        modules.push(ModuleDefinition("", "Quest", false));
    }

    function addModuleDefinition(
        string calldata metadataURI,
        string calldata name,
        bool isStandalone
    ) public onlyOwner override returns (uint) {
        modules.push(ModuleDefinition(metadataURI, name,isStandalone));
    }

    function getAllModules() public view override returns (ModuleDefinition[] memory) {
        return modules;
    }
    function getModuleById(uint moduleId) public view override returns (ModuleDefinition memory) {
        return modules[moduleId];
    }
}
