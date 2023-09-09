//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IDAOExpanderFactory {
    function deployDAOExpander(
        address deployer,
        address autIDAddr,
        address daoTypesAddr,
        uint256 daoType,
        address daoAddr,
        uint256 market,
        string calldata metadata,
        uint256 commitment,
        address pluginRegistry
    ) external returns (address _daoExpanderAddress);
}
