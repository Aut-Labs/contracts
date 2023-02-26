//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IQuestOpenTaskFactory {

    function deployOpenTaskPlugin(address dao, address questsAddress)
        external
        returns (address _pluginAddress);
}
