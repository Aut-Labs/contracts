//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IModuleRegistry.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {IAllowlist} from "../../utils/IAllowlist.sol";

contract ModuleRegistry is IModuleRegistry, Ownable {
    ModuleDefinition[] public modules;
    IAllowlist AllowList;

    constructor(address allList) Ownable(msg.sender) {
        _transferOwnership(msg.sender);
        AllowList = IAllowlist(allList);

        modules.push(ModuleDefinition("none", 0));
        modules.push(
            ModuleDefinition(
                "ipfs://bafkreia2si4nhqjdxg543z7pp5kchvx4auwm7gn54wftfa2vykfkjc4ppe",
                1
            )
        );
        modules.push(
            ModuleDefinition(
                "ipfs://bafkreihxcz6eytmf6lm5oyqee67jujxepuczl42lw2orlfsw6yds5gm46i",
                2
            )
        );
        modules.push(
            ModuleDefinition(
                "ipfs://bafkreieg7dwphs4554g726kalv5ez22hd55k3bksepa6rrvon6gf4mupey",
                3
            )
        );
    }

    function addModuleDefinition(
        string calldata metadataURI
    ) public override onlyOwner returns (uint256) {
        require(bytes(metadataURI).length > 0, "invalid uri");
        uint256 id = modules.length;
        modules.push(ModuleDefinition(metadataURI, id));
        emit ModuleDefinitionAdded(id);
        return id;
    }

    function getAllModules()
        public
        view
        override
        returns (ModuleDefinition[] memory)
    {
        return modules;
    }

    function getModuleById(
        uint256 moduleId
    ) public view override returns (ModuleDefinition memory) {
        return modules[moduleId];
    }

    function updateMetadataURI(
        uint256 moduleId,
        string calldata uri
    ) public override onlyOwner {
        modules[moduleId].metadataURI = uri;
    }

    function isProtocolMaintaier(
        address subject
    ) external view override returns (bool) {
        if (address(AllowList) == address(0)) return false;
        return AllowList.isAllowedOwner(subject);
    }

    function getAllowListAddress() external view returns (address) {
        return address(AllowList);
    }
}
