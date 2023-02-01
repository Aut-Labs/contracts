//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IAutDAOFactory.sol";
import "./AutDAO.sol";

contract AutDAOFactory is IAutDAOFactory {
    function deployAutDAO(
        address deployer,
        address autIDAddr,
        uint256 market,
        string calldata metadata,
        uint256 commitment,
        address pluginRegistry
    ) public override returns (address _autDAOAddress) {
        AutDAO newAutDAO = new AutDAO(
            deployer,
            IAutID(autIDAddr),
            market,
            metadata,
            commitment,
            pluginRegistry
        );
        return address(newAutDAO);
    }
}
