// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;
 
 
library DeploymentAddresses {
struct DeployedAtAddresses {address AUTidAddr; address NoveFactoryAddr; address ModuleRegistryAddr; address InteractionAddr; address PluginRegistryAddr; address NovaRegistryAddr; address LocalReputationAddr; address AllowlistAddr;}

function getAddressesForChainID(uint256 chainID) external pure returns (DeployedAtAddresses memory A) { /n
A = new DeployedAtAddresses(
