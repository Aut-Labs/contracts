// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {NovaFactory} from "../contracts/nova/NovaFactory.sol";
import {NovaRegistry, INovaRegistry} from "../contracts/nova/NovaRegistry.sol";
import {ModuleRegistry, IModuleRegistry} from "../contracts/modules/registry/ModuleRegistry.sol";
import {PluginRegistry, IPluginRegistry} from "../contracts/plugins/PluginRegistry.sol";
import {AutID, IAutID} from "../contracts/AutID.sol";
import {Interaction, IInteraction} from "../contracts/Interaction.sol";
import {SWLegacyDAO} from "../contracts/mocks/SWLegacyCommunity.sol";
import {LocalRep} from "../contracts/plugins/interactions/LocalReputation.sol";

import "forge-std/Script.sol";

contract DeployScript is Script {
    address biconomyTrustedForward;
    uint256 chainID;

    function setUp() public {
        chainID = block.chainid;
        if (chainID == 80001) biconomyTrustedForward = 0x69015912AA33720b842dCD6aC059Ed623F28d9f7;
        if (chainID == 5) biconomyTrustedForward = 0xE041608922d06a4F26C0d4c27d8bCD01daf1f792;

        if (biconomyTrustedForward == address(0)) {
            console.log("ERROR: Only Mumbai and Goerli Testnets Supported");
            console.log("See scripts/DeployAll");
        }
    }

    function run() public {
        vm.startBroadcast(vm.envUint("DEV_PK"));

        console.log("---------------------------------------------------");
        console.log("Deploying to network ID:  ", block.chainid);
        console.log("______________________________________________");

        address AUTid = address(new AutID());
        address NoveFactoryAddr = address(new NovaFactory());
        address ModuleRegistryAddr = address(new ModuleRegistry());
        address InteractionAddr = address(new Interaction());
        address PluginRegistryAddr = address(new PluginRegistry(ModuleRegistryAddr));
        address NovaRegistryAddr =
            address(new NovaRegistry(biconomyTrustedForward,AUTid,NoveFactoryAddr, PluginRegistryAddr ));
        address LocalReputation = address(new LocalRep());

        console.log("AUTid----------------------------------------- : ", AUTid);
        console.log("Nova Factory----------------------------------------- : ", NoveFactoryAddr);
        console.log("ModuleRegistry ----------------------------------------- : ", ModuleRegistryAddr);
        console.log("PluginRegistry ----------------------------------------- : ", PluginRegistryAddr);
        console.log("NovaRegistry ----------------------------------------- : ", NovaRegistryAddr);
        console.log("Interaction ----------------------------------------- : ", InteractionAddr);
        console.log("LocalReputation ----------------------------------------- : ", LocalReputation);
        console.log("                                                                       ");
        console.log("______________________________________________");

        vm.stopBroadcast();
    }
}
