//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IQuestOffchainTaskFactory {
   
    function deployOffchainTaskPlugin(
        address dao,
        address offchainVerifierAddress,
        address questsAddress
    ) external returns (address _pluginAddress);
}
