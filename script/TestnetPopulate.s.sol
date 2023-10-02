// // SPDX-License-Identifier: UNLICENSED
// pragma solidity 0.8.19;

// import {NovaFactory} from "../contracts/nova/NovaFactory.sol";
// import {NovaRegistry, INovaRegistry} from "../contracts/nova/NovaRegistry.sol";
// import {ModuleRegistry, IModuleRegistry} from "../contracts/modules/registry/ModuleRegistry.sol";
// import {PluginRegistry, IPluginRegistry} from "../contracts/plugins/PluginRegistry.sol";
// import {AutID, IAutID} from "../contracts/AutID.sol";
// import {INova} from "../contracts/nova/interfaces/INova.sol";
// // import {SWLegacyDAO} from "../contracts/mocks/SWLegacyCommunity.sol";
// import {LocalReputation} from "../contracts/LocalReputation.sol";

// import {DeploymentAddresses} from "./DeploymentAddresses.sol";
// import "forge-std/Script.sol";

// contract Populate is Script {
//     NovaFactory NovaF;
//     NovaRegistry NovaR;
//     PluginRegistry PlugReg;
//     AutID aID;
//     LocalReputationutation LR;

//     uint256 chainID;
//     address biconomyTrustedForward;

//     function setUp() public {
//         chainID = block.chainid;
//         if (chainID == 80001) biconomyTrustedForward = 0x69015912AA33720b842dCD6aC059Ed623F28d9f7;
//         if (chainID == 5) biconomyTrustedForward = 0xE041608922d06a4F26C0d4c27d8bCD01daf1f792;

//         if (biconomyTrustedForward == address(0)) revert("Unsupported Testnet");

//         aID = AutID(DeploymentAddresses.autIDAddr(chainID));
//         NovaF = NovaFactory(DeploymentAddresses.novaFactoryAddr(chainID));
//         NovaR = NovaRegistry(DeploymentAddresses.novaRegistryAddr(chainID));
//         PlugReg = PluginRegistry(DeploymentAddresses.pluginRegistryAddr(chainID));
//         aID = AutID(DeploymentAddresses.autIDAddr(chainID));
//         LR = LocalReputation(DeploymentAddresses.LocalReputationutationAddr(chainID));
//     }

//     function run() public {
//         uint256[] memory privateKeys = new uint256[](3);
//         privateKeys[0] = vm.envUint("A1");
//         privateKeys[1] = vm.envUint("A2");
//         privateKeys[2] = vm.envUint("A3");

//         uint256 i;

//         INova OurNova = INova(
//             NovaF.deployNova(vm.addr(privateKeys[0]), address(aID), 0, "this is a metadata string", 9, address(PlugReg))
//         );

//         for (i; i < privateKeys.length;) {
//             console.log("###########################################");
//             console.log("o_o : ", vm.addr(privateKeys[i]));
//             console.log("###########################################");

//             vm.startBroadcast(privateKeys[i]);

//             /// install plugin

//             /// prank Agent 1 - repeat for each user

//             /// Agent joins nova

//             /// Agent does reputation bearing task

//             /// Period flip 1

//             /// Agent does reputation bearing task 2

//             console.log("###########################################");

//             vm.stopBroadcast();
//             unchecked {
//                 ++i;
//             }
//         }
//     }
// }
