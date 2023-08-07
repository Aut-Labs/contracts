// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {NovaFactory, INovaFactory} from "../contracts/nova/NovaFactory.sol";
import {NovaRegistry, INovaRegistry} from "../contracts/nova/NovaRegistry.sol";
import {ModuleRegistry, IModuleRegistry} from "../contracts/modules/registry/ModuleRegistry.sol";
import {PluginRegistry, IPluginRegistry} from "../contracts/plugins/PluginRegistry.sol";
import {AutID, IAutID} from "../contracts/AutID.sol";
import {Interaction, IInteraction} from "../contracts/Interaction.sol";

import {SWLegacyDAO} from "../contracts/mocks/SWLegacyCommunity.sol";

//// @notice Tests Basic Deployment attainable
contract DeploysInit is Test {
    IAutID aID;
    INovaRegistry INR;
    INovaFactory NovaFactor;
    IInteraction Interact;
    IPluginRegistry IPR;
    IModuleRegistry IMR;
    SWLegacyDAO LegacyDAO;

    address A0 = address(uint160(uint256(keccak256("Account0 Deployer"))));

    address A1;
    address A2;
    address A3;

    function setUp() public virtual {
        address A1 = address(uint160(uint256(keccak256("Account1"))));
        vm.label(address(A1), "Account1");

        address A2 = address(uint160(uint256(keccak256("Account2"))));
        vm.label(address(A2), "Account2");

        address A3 = address(uint160(uint256(keccak256("Account1"))));
        vm.label(address(A3), "Account3");

        LegacyDAO = new SWLegacyDAO();
        vm.label(address(LegacyDAO), "LegacyDAOI");

        aID = IAutID(address(new AutID()));
        vm.label(address(aID), "AutIDI");
        NovaFactor = INovaFactory(address(new NovaFactory()));
        vm.label(address(NovaFactor), "NovaFactoryI");

        Interact = IInteraction(address(new Interaction()));
        vm.label(address(Interact), "InteractionI");

        IMR = IModuleRegistry(address(new ModuleRegistry()));
        vm.label(address(IMR), "ModuleRegistryI");

        IPR = IPluginRegistry(
            address(
                new PluginRegistry(address(IMR)
                )
            )
        );
        vm.label(address(IPR), "PluginRegistryI");

        INR = INovaRegistry(address(new NovaRegistry(address(12345),address(aID), address(NovaFactor), address(IPR))));
        vm.label(address(INR), "NovaRegistryI");
    }

    function testAreDeployedContracts() public {
        assertTrue(address(aID).code.length > 1, "expected aID contract");
        assertTrue(address(NovaFactor).code.length > 2, "expected NovaFactor contract");
        assertTrue(address(Interact).code.length > 3, "expected Interact contract");
        assertTrue(address(IMR).code.length > 4, "expected IMR contract");
        assertTrue(address(IPR).code.length > 5, "expected IPR contract");
        assertTrue(address(INR).code.length > 6, "expected INRcontract");
    }
}