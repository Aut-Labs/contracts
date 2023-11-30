// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Nova} from "../contracts/nova/Nova.sol";
import {NovaRegistry, INovaRegistry} from "../contracts/nova/NovaRegistry.sol";
import {ModuleRegistry, IModuleRegistry} from "../contracts/modules/registry/ModuleRegistry.sol";
import {PluginRegistry, IPluginRegistry} from "../contracts/plugins/PluginRegistry.sol";
import {AutID, IAutID} from "../contracts/AutID.sol";
import {SWLegacyDAO} from "../contracts/mocks/SWLegacyCommunity.sol";
import {LocalReputation} from "../contracts/LocalReputation.sol";
import {TrustedForwarder} from "../contracts/mocks/TrustedForwarder.sol";

import {IAllowlist, Allowlist} from "../contracts/utils/Allowlist.sol";

// import {AddToAllowList} from "./AddToAllowList.s.sol";

import "forge-std/Script.sol";

contract DeployScript is Script {
    address biconomyTrustedForward;
    uint256 chainID;

    // AddToAllowList AddALL;
    /// plugin definition hardcoded init metadatauri
    string joinDisocrdUrl = "ipfs://bafkreiczcramssdxwman5yry2xexqvjqxjix7fz7eeiekuqbkusuxnqkym";
    string openTaskUrl = "ipfs://bafkreibycwcobqp4ietiownx2y63us6f4kxte5ql6dsvmpurggsqkbgnj4";
    string quizUrl = "ipfs://bafkreibs7zxogv4j2acclnliuqbj2rhcpc7xf4fovbe3gu4lta76ie4hsq";
    string socialBotUrl = "ipfs://bafkreifeesdwui5ly2wscrtu5xiztb7mk4gypvu4fjhpu5kyspasld2fze";
    string socialQuizUrl = "ipfs://bafkreibu4wyucyrvb3wkd3blwhc4n2ayg7sugpl7egxrdglsorlvpkekv4";

    function setUp() public {
        chainID = block.chainid;
        if (chainID == 80001) biconomyTrustedForward = 0x69015912AA33720b842dCD6aC059Ed623F28d9f7;
        if (chainID == 5) biconomyTrustedForward = 0xE041608922d06a4F26C0d4c27d8bCD01daf1f792;
        if (chainID == 31337) biconomyTrustedForward = address(new TrustedForwarder());
        // if ((8001 * 5 * 31337 * 1000) % chainID != 0 )  biconomyTrustedForward = address(128);
        if (biconomyTrustedForward == address(0)) {
            console.log("ERROR: Only Mumbai and Goerli Testnets Supported");
            console.log("See scripts/DeployAll");
        }

        vm.writeFile(
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
        vm.startBroadcast(vm.envUint("PVK_A1"));

        console.log("---------------------------------------------------");
        console.log("Deploying to network ID:  ", block.chainid);
        console.log("______________________________________________");

        vm.writeFile(
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
        vm.writeLine("deployments.txt", string.concat("Deployer address: ", vm.toString(vm.addr(vm.envUint("PVK_A1")))));

        address NovaLogicAddr = address(new Nova());
        address AUTid = address(new AutID());

        address AllowlistAddr = address(new Allowlist());
        address ModuleRegistryAddr = address(new ModuleRegistry(AllowlistAddr));
        address PluginRegistryAddr = address(new PluginRegistry(ModuleRegistryAddr));
                address LocalReputationAddr = address(new LocalReputation(address(PluginRegistryAddr)));
        address NovaRegistryAddr = address(
            new NovaRegistry(
                    biconomyTrustedForward,
                    AUTid,
                    NovaLogicAddr,
                    PluginRegistryAddr
                )
        );

        IAllowlist(AllowlistAddr).addOwner(0x1b403ff6EB37D25dCCbA0540637D65550f84aCB3);
        IAllowlist(AllowlistAddr).addOwner(0x303b24d8bB5AED7E55558aEF96B282a84ECfa82a);
        IAllowlist(AllowlistAddr).addOwner(0x09Ed23BB6F9Ccc3Fd9b3BC4C859D049bf4AB4D43);
        IAllowlist(AllowlistAddr).addOwner(0xcD3942171C362448cBD4FAeA6b2B71c8cCe40BF3);
        IAllowlist(AllowlistAddr).addOwner(0x91dD610E5cBe132A833F42c2dF0b2eafa965DA40);
        IAllowlist(AllowlistAddr).addOwner(0x7660aa261d27A2A32d4e7e605C1bc2BA515E5f81);
        IAllowlist(AllowlistAddr).addOwner(0x55954C2C092f6e973B55C5D2Af28950b3b6D1338);
        IAllowlist(AllowlistAddr).addOwner(0x06a0cC2bF3F4B1b7f725ccaB1D7A51547c48B8Fc);
        IAllowlist(AllowlistAddr).addOwner(0x61Be760b4fFb521657f585b392E3a446F4BB563d);

        vm.writeLine(
            "deployments.txt",
            string.concat(
                string.concat(
                    "AUTid----------------------------------------- : ",
                    vm.toString(AUTid),
                    " \n",
                    "Nova Logic----------------------------------------- : ",
                    vm.toString(NovaLogicAddr),
                    " \n"
                ),
                string.concat(
                    "ModuleRegistry----------------------------------------- : ",
                    vm.toString(ModuleRegistryAddr),
                    " \n",
                    "PluginRegistry----------------------------------------- : ",
                    vm.toString(PluginRegistryAddr),
                    " \n",
                    "NovaRegistry----------------------------------------- : ",
                    vm.toString(NovaRegistryAddr),
                    " \n"
                ),
                string.concat(
                    "LocalReputation----------------------------------------- : ",
                    vm.toString(LocalReputationAddr),
                    " \n",
                    "AllowlistAddr----------------------------------------- : ",
                    vm.toString(AllowlistAddr),
                    " \n"
                )
            )
        );

        ////////////////////////////////////////////////////////
        //////// set changable contracts
        IPluginRegistry IPR = IPluginRegistry(PluginRegistryAddr);
        IPR.setDefaulLRAddress(LocalReputationAddr);

        uint256[] memory dependencies;
        uint256[] memory pluginDefinitionIds = new uint256[](6);

        pluginDefinitionIds[0] = IPR.addPluginDefinition(
            payable(address(0x303b24d8bB5AED7E55558aEF96B282a84ECfa82a)), joinDisocrdUrl, 0, true, dependencies
        );
        pluginDefinitionIds[1] = IPR.addPluginDefinition(
            payable(address(0x303b24d8bB5AED7E55558aEF96B282a84ECfa82a)), openTaskUrl, 0, true, dependencies
        );
        pluginDefinitionIds[2] = IPR.addPluginDefinition(
            payable(address(0x303b24d8bB5AED7E55558aEF96B282a84ECfa82a)), quizUrl, 0, true, dependencies
        );
        pluginDefinitionIds[3] = IPR.addPluginDefinition(
            payable(address(0x303b24d8bB5AED7E55558aEF96B282a84ECfa82a)), socialBotUrl, 0, true, dependencies
        );
        pluginDefinitionIds[4] = IPR.addPluginDefinition(
            payable(address(0x303b24d8bB5AED7E55558aEF96B282a84ECfa82a)), socialQuizUrl, 0, true, dependencies
        );

        // vm.writeLine(
        //     "deployments.txt",
        //     string.concat(
        //         "PluginIDs : ",
        //         vm.toString(pluginDefinitionIds[0]),
        //         " , ",
        //         vm.toString(pluginDefinitionIds[1]),
        //         " , ",
        //         vm.toString(pluginDefinitionIds[2]),
        //         " , ",
        //         vm.toString(pluginDefinitionIds[3])
        //     )
        // );

        console.log("AUTid----------------------------------------- : ", AUTid);
        console.log("Nova Logic----------------------------------------- : ", NovaLogicAddr);
        console.log("ModuleRegistry ----------------------------------------- : ", ModuleRegistryAddr);
        console.log("PluginRegistry ----------------------------------------- : ", PluginRegistryAddr);
        console.log("NovaRegistry ----------------------------------------- : ", NovaRegistryAddr);
        console.log("LocalReputation ----------------------------------------- : ", LocalReputationAddr);
        console.log("Allowlist ----------------------------------------- : ", AllowlistAddr);
        console.log("                                                                       ");
        console.log("______________________________________________");

        vm.stopBroadcast();
    }
}
