//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IDAOExpanderFactory {
    function deployDAOExpander(
        address deployer,
        address autIDAddr,
        address daoTypesAddr,
        uint256 daoType,
        address daoAddr,
        uint256 market,
        string calldata metadata,
        uint256 commitment
    ) external returns (address _daoExpanderAddress);
}
