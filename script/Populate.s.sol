// SPDX-License-Identifier: MIT
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

contract Populate is Script {}
