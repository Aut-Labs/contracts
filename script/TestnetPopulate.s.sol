// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Nova} from "../contracts/nova/Nova.sol";
import {NovaRegistry, INovaRegistry} from "../contracts/nova/NovaRegistry.sol";
import {ModuleRegistry, IModuleRegistry} from "../contracts/modules/registry/ModuleRegistry.sol";
import {PluginRegistry, IPluginRegistry} from "../contracts/plugins/PluginRegistry.sol";
import {AutID, IAutID} from "../contracts/AutID.sol";
import {INova} from "../contracts/nova/interfaces/INova.sol";
import {LocalReputation} from "../contracts/LocalReputation.sol";

import {OpenTaskWithRep} from "../contracts/plugins/interactions/OpenTaskWithRep.sol";
import {SocialBotPlugin} from "../contracts/plugins/interactions/SocialBotPlugin.sol";
import {SocialQuizPlugin} from "../contracts/plugins/interactions/SocialQuizPlugin.sol";

import {DeploymentAddresses} from "./DeploymentAddresses.sol";

import "forge-std/Script.sol";

contract Populate is Script {
    Nova NovaL;
    NovaRegistry NovaR;
    PluginRegistry PlugReg;
    AutID aID;
    LocalReputation LR;
    OpenTaskWithRep OpenTaskWR;
    SocialBotPlugin SBPlugin;
    SocialQuizPlugin SQPlugin;

    INova Nova1;

    address deployer = vm.rememberKey(vm.envUint("PVK_A1"));

    uint256 chainID;
    address biconomyTrustedForward;

    function setUp() public {
        chainID = block.chainid;
        if (chainID == 80001) biconomyTrustedForward = 0x69015912AA33720b842dCD6aC059Ed623F28d9f7;
        if (chainID == 5) biconomyTrustedForward = 0xE041608922d06a4F26C0d4c27d8bCD01daf1f792;

        if (biconomyTrustedForward == address(0)) revert("Unsupported Testnet");

        aID = AutID(DeploymentAddresses.autIDAddr(chainID));
        vm.label(address(aID), "AutID");
        NovaL = Nova(DeploymentAddresses.novaLogicAddr(chainID));
        vm.label(address(NovaL), "Nova Logic");

        NovaR = NovaRegistry(DeploymentAddresses.novaRegistryAddr(chainID));
        vm.label(address(NovaR), "NovaR");

        PlugReg = PluginRegistry(DeploymentAddresses.pluginRegistryAddr(chainID));
        vm.label(address(PlugReg), "PluginRegistry");

        LR = LocalReputation(DeploymentAddresses.LocalReputationutationAddr(chainID));
        vm.label(address(LR), "LocalReputation");
    }

    function run() public {
        uint256[] memory privateKeys = new uint256[](3);
        privateKeys[0] = vm.envUint("PVK_A1");
        /// deployer
        privateKeys[1] = vm.envUint("PVK_A2");
        privateKeys[2] = vm.envUint("PVK_A3");

        vm.startBroadcast(deployer); //////////////////////// BROADCAST

        uint256[] memory deps;

        uint256 pluginDefBot1 = PlugReg.addPluginDefinition(
            payable(address(deployer)),
            "ipfs://bafkreidz4ik2na4wj54ha3kvjjauaxkumd3xrejpvqbt7vzdekw4vzgvqy",
            0,
            true,
            deps
        );
        uint256 pluginDefOpenTask = PlugReg.addPluginDefinition(
            payable(address(deployer)),
            "ipfs://bafkreie45ntwx6trhl4azaixj6st64rcghrnscf2mnlahihctri6ospgte",
            0,
            true,
            deps
        );
        uint256 pluginQuizBot2 = PlugReg.addPluginDefinition(
            payable(address(deployer)),
            "ipfs://bafkreidz4ik2na4wj54ha3kvjjauaxkumd3xrejpvqbt7vzdekw4vzgvqy",
            0,
            true,
            deps
        );

        INova OurNova = INova(NovaR.deployNova(1, "this is a metadata string", 1));

        address botPluginAddr = address(new SocialBotPlugin(address(OurNova)));
        address botQuizAddr = address(new SocialQuizPlugin(address(OurNova)));
        address openTask = address(new OpenTaskWithRep(address(OurNova)));

        PlugReg.addPluginToNova(botPluginAddr, pluginDefBot1);
        PlugReg.addPluginToNova(botQuizAddr, pluginQuizBot2);
        PlugReg.addPluginToNova(openTask, pluginDefOpenTask);

        LR.setKP(LR.DEFAULT_K(), 90, LR.DEFAULT_PENALTY(), address(OurNova));
        address[] memory adminAddresses = new address[](5);
        adminAddresses[0] = 0x1b403ff6EB37D25dCCbA0540637D65550f84aCB3;
        adminAddresses[1] = 0x303b24d8bB5AED7E55558aEF96B282a84ECfa82a;
        adminAddresses[2] = 0x09Ed23BB6F9Ccc3Fd9b3BC4C859D049bf4AB4D43;
        adminAddresses[3] = 0x35C92Dd11F4768691e0B66d5B735e9ddE8abE5ad;
        adminAddresses[4] = 0xCa0a610A75EA146d4ee94824E858B362Ef46Cc29;

        OurNova.addAdmins(adminAddresses);
        vm.stopBroadcast(); /////////////////// BROADCAST END

        uint256 i = 1;

        for (i; i < privateKeys.length;) {
            console.log("###########################################");
            console.log(string.concat("o_o Account ", vm.toString(i)), vm.addr(privateKeys[i]));
            console.log("###########################################");

            vm.startBroadcast(privateKeys[i]);

            // aID.joinDAO(1, i + 3 > 10 ? i : i + 3, address(OurNova));

            aID.mint(
                string.concat("MojoJoJo_- ", vm.toString(i)),
                "http://IamanURL.xyz.abc.com",
                i % 2 == 0 ? 1 : 3,
                i + 3 > 10 ? i : i + 3,
                address(OurNova)
            );
            /// Agent joins nova

            /// Agent does reputation bearing task

            /// Period flip 1

            /// Agent does reputation bearing task 2

            console.log("###########################################");

            vm.stopBroadcast();
            unchecked {
                ++i;
            }
        }
    }
}
