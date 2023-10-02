// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "../../modules/archetypes/ArchetypesModule.sol";
import "../../daoUtils/interfaces/get/IDAOAdmin.sol";
import "../SimplePlugin.sol";

contract ArchetypesPlugin is ArchetypesModule, SimplePlugin {
    uint8 public constant SIZE = 1;
    uint8 public constant REPUTATION = 2;
    uint8 public constant CONVICTION = 3;
    uint8 public constant PERFORMANCE = 4;
    uint8 public constant GROWTH = 5;

    uint8 public mainArchetype;
    mapping(uint8 => uint256) public archetypeWeightFor;

    modifier onlyAdmin() {
        require(IDAOAdmin(daoAddress()).isAdmin(msg.sender), "Not an admin.");
        _;
    }

    constructor(address dao) SimplePlugin(dao, 7) {
        _deployer = msg.sender;
    }

    function setMainArchetype(uint8 archetype) external onlyAdmin {
        if (mainArchetype != 0) {
            revert ArchetypeAlreadySet();
        }
        _validateArchetype(archetype);
        mainArchetype = archetype;   
        _setActive(true);
    }

    function setArchetypeWeightFor(
        uint8 archetype,
        uint256 value
    )
        external
        onlyAdmin 
    {
        _validateArchetype(archetype);
        archetypeWeightFor[archetype] = value;
    }

    function _validateArchetype(uint8 archetype) internal pure {
        if (archetype > 5 || archetype == 0) {
            revert WrongArchetype();
        }
    }
}
