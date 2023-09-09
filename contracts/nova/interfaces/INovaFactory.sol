//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface INovaFactory {
    function deployNova(
        address deployer,
        address autIDAddr,
        uint256 market,
        string calldata metadata,
        uint256 commitment,
        address pluginRegistry
    ) external returns (address _nova);
}
