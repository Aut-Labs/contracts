//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INovaRegistry {
    function deployNova(uint256 market, string calldata metadata, uint256 commitment)
        external
        returns (address _nova);

    //// View

    function checkNova(address) external view returns(bool);
    function getNovas() external view returns (address[] memory);
    function getNovaByDeployer(address deployer) external view returns (address[] memory);
    function autIDAddr() external view returns (address);
    function pluginRegistry() external view returns (address);
}
