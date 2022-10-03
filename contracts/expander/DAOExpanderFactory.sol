//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IDAOExpanderFactory.sol";
import "./DAOExpander.sol";

contract DAOExpanderFactory is IDAOExpanderFactory {

    function deployDAOExpander(
        address deployer,
        address autIDAddr,
        address daoTypesAddr,
        uint256 daoType,
        address daoAddr,
        uint256 market,
        string calldata metadata,
        uint256 commitment
    ) public override returns (address _daoExpanderAddress) {
        DAOExpander newDAOExpander = new DAOExpander(
            deployer,
            autIDAddr,
            daoTypesAddr,
            daoType,
            daoAddr,
            market,
            metadata,
            commitment
        );
        return address(newDAOExpander);
    }
}
