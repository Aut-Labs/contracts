// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {NovaFactory} from "../contracts/nova/NovaFactory.sol";
import {NovaRegistry, INovaRegistry} from "../contracts/nova/NovaRegistry.sol";
import {ModuleRegistry, IModuleRegistry} from "../contracts/modules/registry/ModuleRegistry.sol";
import {PluginRegistry, IPluginRegistry} from "../contracts/plugins/PluginRegistry.sol";
import {AutID, IAutID} from "../contracts/AutID.sol";
import {SWLegacyDAO} from "../contracts/mocks/SWLegacyCommunity.sol";
import {LocalReputation} from "../contracts/LocalReputation.sol";

import {IAllowlist, Allowlist} from "../contracts/utils/Allowlist.sol";


import "forge-std/Script.sol";

contract DeployScript is Script {
    address biconomyTrustedForward;
    uint256 chainID;

    /// plugin definition hardcoded init metadatauri
    string onboardingIpfsUrl = "ipfs://bafkreig3gwhmraeljunek6rw3vynsbxapmwdmtzaov6uwcsq4qz6t2kmny";
    string discordUrl = "ipfs://bafkreic6s52eavmst3w7vebsdzl76a55wbm3asq6qujubjh6xh3323u7f4";
    string openTaskUrl = "ipfs://bafkreie45ntwx6trhl4azaixj6st64rcghrnscf2mnlahihctri6ospgte";
    string quizUrl = "ipfs://bafkreign362uxbfxfmczqd73accyqvfllmf5p47lxyubmdxylhin5xdazi";
    string socialBotUrl = "ipfs://bafkreidz4ik2na4wj54ha3kvjjauaxkumd3xrejpvqbt7vzdekw4vzgvqy";
    string transactionTaskUrl = "ipfs://bafkreidlrxr57x7f3pfen35kzorqxnkfatuc5brofgpztty3qi5eis6f6a";





    function setUp() public {
        chainID = block.chainid;
        if (chainID == 80001) biconomyTrustedForward = 0x69015912AA33720b842dCD6aC059Ed623F28d9f7;
        if (chainID == 5) biconomyTrustedForward = 0xE041608922d06a4F26C0d4c27d8bCD01daf1f792;

        if (biconomyTrustedForward == address(0)) {
            console.log("ERROR: Only Mumbai and Goerli Testnets Supported");
            console.log("See scripts/DeployAll");
        }
        vm.writeLine(
            "deployments.txt",
            string.concat(" \n", " \n", "#################################################################### \n")
        );

        vm.writeLine(
            "deployments.txt",
            " ####################################################################### \n ####################### DEPLOYMENT ADDRESSES ########################## \n ####################################################################### \n"
        );

        // vm.writeFile(
        //     "script/DeploymentAddresses.sol",
        //     string.concat("// SPDX-License-Identifier: UNLICENSED\n", "pragma solidity 0.8.19;\n \n \n")
        // );

        // vm.writeLine(
        //     "script/DeploymentAddresses.sol",
        //     string.concat(
        //         "library DeploymentAddresses {\n",
        //         "struct DeployedAtAddresses {address AUTidAddr; address NoveFactoryAddr; address ModuleRegistryAddr; address InteractionAddr; address PluginRegistryAddr; address NovaRegistryAddr; address LocalReputationAddr; address AllowlistAddr;}\n"
        //     )
        // );

        /// {
        // vm.writeLine(
        //     "script/DeploymentAddresses.sol",
        //     "function getAddressesForChainID(uint256 chainID) external pure returns (DeployedAtAddresses memory A) { /n"
        // );

        // vm.writeLine("script/DeploymentAddresses.sol", "A = new DeployedAtAddresses(");
    }

    function run() public {
    {
        vm.startBroadcast(vm.envUint("DEV_PK"));

        console.log("---------------------------------------------------");
        console.log("Deploying to network ID:  ", block.chainid);
        console.log("______________________________________________");

                vm.writeLine(
            "deployments.txt",
            string.concat(
                "Deployed to network ID:  ",
                vm.toString(block.chainid),
                " \n",
                "At timestamp:  ",
                vm.toString(block.timestamp),
                " \n",
                "#################################################################### \n"
            )
        );
    }

    //     function addPluginDefinition(
    //     address payable creator,
    //     string memory metadataURI,
    //     uint256 price,
    //     bool canBeStandalone,
    //     uint256[] memory moduleDependencies
    // ) external returns (uint256 pluginDefinitionId) 

        address LocalReputationAddr = address(new LocalReputation());
        address AUTid = address(new AutID());

        address AllowlistAddr = address(new Allowlist());
        address NoveFactoryAddr = address(new NovaFactory());
        address ModuleRegistryAddr = address(new ModuleRegistry(AllowlistAddr));
        address PluginRegistryAddr = address(new PluginRegistry(ModuleRegistryAddr));
        address NovaRegistryAddr =
            address(new NovaRegistry(biconomyTrustedForward,AUTid,NoveFactoryAddr, PluginRegistryAddr ));
        
        ////////////////////////////////////////////////////////
        //////// set changable contracts
        IPluginRegistry IPR = IPluginRegistry(PluginRegistryAddr);
        IPR.setDefaulLRAddress(LocalReputationAddr);

        uint256[] memory dependencies;
        uint256[] memory pluginDefinitionIds = new uint256[](6);


        pluginDefinitionIds[0] =IPR.addPluginDefinition(payable(address(0x303b24d8bB5AED7E55558aEF96B282a84ECfa82a)), onboardingIpfsUrl, 0,true,dependencies);
        pluginDefinitionIds[1] =IPR.addPluginDefinition(payable(address(0x303b24d8bB5AED7E55558aEF96B282a84ECfa82a)), discordUrl, 0,true,dependencies);
        pluginDefinitionIds[2] =IPR.addPluginDefinition(payable(address(0x303b24d8bB5AED7E55558aEF96B282a84ECfa82a)), openTaskUrl, 0,true,dependencies);
        pluginDefinitionIds[3] =IPR.addPluginDefinition(payable(address(0x303b24d8bB5AED7E55558aEF96B282a84ECfa82a)), quizUrl, 0,true,dependencies);
        pluginDefinitionIds[4] =IPR.addPluginDefinition(payable(address(0x303b24d8bB5AED7E55558aEF96B282a84ECfa82a)), socialBotUrl, 0,true,dependencies);
        pluginDefinitionIds[5] =IPR.addPluginDefinition(payable(address(0x303b24d8bB5AED7E55558aEF96B282a84ECfa82a)), transactionTaskUrl, 0,true,dependencies);

        

        // vm.writeLine("script/DeploymentAddresses.sol", vm.toString(AUTid));

        // vm.writeLine("script/DeploymentAddresses.sol", vm.toString(NoveFactoryAddr));
        // vm.writeLine("script/DeploymentAddresses.sol", vm.toString(ModuleRegistryAddr));
        // vm.writeLine("script/DeploymentAddresses.sol", vm.toString(PluginRegistryAddr));
        // vm.writeLine("script/DeploymentAddresses.sol", vm.toString(NovaRegistryAddr));
        // vm.writeLine("script/DeploymentAddresses.sol", vm.toString(LocalReputationAddr));
        // vm.writeLine("script/DeploymentAddresses.sol", vm.toString(AllowlistAddr));

        // vm.writeLine("script/DeploymentAddresses.sol", "); /n");

        /// }
        // vm.writeLine("script/DeploymentAddresses.sol", "} /n");

        // vm.writeLine("script/DeploymentAddresses.sol", "}\n");

        IAllowlist(AllowlistAddr).addOwner(0x1b403ff6EB37D25dCCbA0540637D65550f84aCB3);
        IAllowlist(AllowlistAddr).addOwner(0x303b24d8bB5AED7E55558aEF96B282a84ECfa82a);
        IAllowlist(AllowlistAddr).addOwner(0x09Ed23BB6F9Ccc3Fd9b3BC4C859D049bf4AB4D43);

        console.log("AUTid----------------------------------------- : ", AUTid);
        console.log("Nova Factory----------------------------------------- : ", NoveFactoryAddr);
        console.log("ModuleRegistry ----------------------------------------- : ", ModuleRegistryAddr);
        console.log("PluginRegistry ----------------------------------------- : ", PluginRegistryAddr);
        console.log("NovaRegistry ----------------------------------------- : ", NovaRegistryAddr);
        console.log("LocalReputation ----------------------------------------- : ", LocalReputationAddr);
        console.log("Allowlist ----------------------------------------- : ", AllowlistAddr);
        console.log("                                                                       ");
        console.log("______________________________________________");


        vm.writeLine(
            "deployments.txt",
            string.concat(
                string.concat("AUTid----------------------------------------- : ", vm.toString(AUTid), " \n",
                    "Nova Factory----------------------------------------- : ", vm.toString(NoveFactoryAddr), " \n"
                ),
                string.concat(
                    "ModuleRegistry----------------------------------------- : ", vm.toString(ModuleRegistryAddr), " \n",
                    "PluginRegistry----------------------------------------- : ", vm.toString(PluginRegistryAddr), " \n",
                    "NovaRegistry----------------------------------------- : ", vm.toString(NovaRegistryAddr), " \n",
                    "NovaRegistry----------------------------------------- : ", vm.toString(NovaRegistryAddr), " \n"
                ),
                string.concat(
                    "LocalReputation----------------------------------------- : ",
                    vm.toString(LocalReputationAddr),
                    " \n",
                    "AllowlistAddr----------------------------------------- : ",
                    vm.toString(AllowlistAddr),
                    " \n"
                ),
                                string.concat(
                    "PluginIDs : ",
                    vm.toString(pluginDefinitionIds[0]), " , ", vm.toString(pluginDefinitionIds[1]), " , ", vm.toString(pluginDefinitionIds[2]), " , ", vm.toString(pluginDefinitionIds[3])
                )
            )
        );

        vm.stopBroadcast();
    }
}
