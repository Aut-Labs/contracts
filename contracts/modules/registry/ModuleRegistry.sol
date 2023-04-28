//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IModuleRegistry.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ModuleRegistry is IModuleRegistry, Ownable {
    ModuleDefinition[] public modules;

    constructor() {
        _transferOwnership(msg.sender);
        // TODO: put metadata;
        modules.push(ModuleDefinition("none", 0));
        modules.push(ModuleDefinition("ipfs://bafkreiajwhzd36nkt44bqgtyh7upkgoiooxqzafp62qh4zagkfihcssgpu", 1));
        modules.push(ModuleDefinition("ipfs://bafkreihxcz6eytmf6lm5oyqee67jujxepuczl42lw2orlfsw6yds5gm46i", 2));
        modules.push(ModuleDefinition("ipfs://bafkreieg7dwphs4554g726kalv5ez22hd55k3bksepa6rrvon6gf4mupey", 3));
    }

    function addModuleDefinition(
        string calldata metadataURI
    ) public onlyOwner override returns (uint) {
        require(bytes(metadataURI).length > 0, 'invalid uri');
        uint id = modules.length;
        modules.push(ModuleDefinition(metadataURI, id));
        emit ModuleDefinitionAdded(id);
        return id;
    }

    function getAllModules() public view override returns (ModuleDefinition[] memory) {
        return modules;
    }
    function getModuleById(uint moduleId) public view override returns (ModuleDefinition memory) {
        return modules[moduleId];
    }

    function updateMetadataURI(uint moduleId, string calldata uri) onlyOwner public override {
         modules[moduleId].metadataURI = uri;
    }
}
