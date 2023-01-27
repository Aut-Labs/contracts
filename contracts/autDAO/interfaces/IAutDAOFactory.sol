//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAutDAOFactory {
    function deployAutDAO(
        address deployer,
        address autIDAddr,
        uint256 market,
        string calldata metadata,
        uint256 commitment,
        address pluginRegistry
    ) external returns (address _autDAO);
}
